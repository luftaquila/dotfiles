#!/usr/bin/env node
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { execFileSync } from 'child_process';
import { tmpdir, homedir, userInfo, hostname } from 'os';
import { createHash } from 'crypto';
import https from 'https';

const CACHE_PATH = join(homedir(), '.claude', 'hud', '.usage-cache.json');
const PROFILE_CACHE_PATH = join(homedir(), '.claude', 'hud', '.profile-cache.json');
const SESSION_FILE = join(tmpdir(), 'claude-hud-sessions.json');
const CACHE_TTL_MS = 90_000;
const ERROR_CACHE_TTL_MS = 300_000; // 5min backoff on API errors (429 etc.)
const JITTER_MS = 30_000; // random jitter to prevent thundering herd
const PROFILE_CACHE_TTL_MS = 86_400_000; // 24h
const API_TIMEOUT_MS = 8000;

// ANSI colors
const R = '\x1b[0m';
const gray = s => `\x1b[90m${s}${R}`;
const green = s => `\x1b[32m${s}${R}`;
const yellow = s => `\x1b[33m${s}${R}`;
const red = s => `\x1b[31m${s}${R}`;
const cyan = s => `\x1b[36m${s}${R}`;
const blue = s => `\x1b[34m${s}${R}`;
const mag = s => `\x1b[35m${s}${R}`;

function color(pct) {
  if (pct >= 90) return red;
  if (pct >= 70) return yellow;
  return green;
}

function fmt(ms) {
  if (ms <= 0) return '0m';
  const d = Math.floor(ms / 86400000);
  const h = Math.floor((ms % 86400000) / 3600000);
  const m = Math.floor((ms % 3600000) / 60000);
  if (d > 0) return `${d}d${h}h`;
  if (h > 0) return `${h}h${m.toString().padStart(2, '0')}m`;
  return `${m}m`;
}

function fmtReset(isoStr) {
  if (!isoStr) return null;
  const diff = new Date(isoStr).getTime() - Date.now();
  return diff > 0 ? fmt(diff) : null;
}

// --- OAuth credentials from macOS Keychain ---
function getKeychainServiceName() {
  const configDir = process.env.CLAUDE_CONFIG_DIR;
  if (configDir) {
    const hash = createHash('sha256').update(configDir).digest('hex').slice(0, 8);
    return `Claude Code-credentials-${hash}`;
  }
  return 'Claude Code-credentials';
}

function readKeychain() {
  if (process.platform === 'darwin') {
    const service = getKeychainServiceName();
    const accounts = [];
    try { accounts.push(userInfo().username?.trim()); } catch {}
    accounts.push(undefined);

    for (const acct of accounts) {
      try {
        const args = acct
          ? ['find-generic-password', '-s', service, '-a', acct, '-w']
          : ['find-generic-password', '-s', service, '-w'];
        const raw = execFileSync('/usr/bin/security', args, {
          encoding: 'utf-8', timeout: 2000, stdio: ['pipe', 'pipe', 'pipe'],
        }).trim();
        if (!raw) continue;
        const parsed = JSON.parse(raw);
        const creds = parsed.claudeAiOauth || parsed;
        if (creds.accessToken) return creds.accessToken;
      } catch {}
    }
  }

  // file fallback (all platforms)
  try {
    const credPath = join(homedir(), '.claude', '.credentials.json');
    if (existsSync(credPath)) {
      const parsed = JSON.parse(readFileSync(credPath, 'utf-8'));
      const creds = parsed.claudeAiOauth || parsed;
      if (creds.accessToken) return creds.accessToken;
    }
  } catch {}
  return null;
}

// --- Profile API ---
function fetchProfile(token) {
  return new Promise(resolve => {
    const req = https.request({
      hostname: 'api.anthropic.com',
      path: '/api/oauth/profile',
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` },
      timeout: API_TIMEOUT_MS,
    }, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        if (res.statusCode === 200) {
          try { resolve(JSON.parse(data)); } catch { resolve(null); }
        } else resolve(null);
      });
    });
    req.on('error', () => resolve(null));
    req.on('timeout', () => { req.destroy(); resolve(null); });
    req.end();
  });
}

async function getProfileName() {
  const token = readKeychain();
  const tokenHash = token ? createHash('sha256').update(token).digest('hex').slice(0, 16) : null;

  try {
    if (existsSync(PROFILE_CACHE_PATH)) {
      const cache = JSON.parse(readFileSync(PROFILE_CACHE_PATH, 'utf-8'));
      if (cache.name && cache.tokenHash === tokenHash && Date.now() - cache.timestamp < PROFILE_CACHE_TTL_MS)
        return cache.name;
    }
  } catch {}

  if (!token) return null;

  const resp = await fetchProfile(token);
  const name = resp?.account?.display_name || resp?.account?.full_name || null;
  if (name) {
    try {
      const dir = dirname(PROFILE_CACHE_PATH);
      if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
      writeFileSync(PROFILE_CACHE_PATH, JSON.stringify({ timestamp: Date.now(), name, tokenHash }));
    } catch {}
  }
  return name;
}

// --- Usage API ---
function fetchUsage(token) {
  return new Promise(resolve => {
    const req = https.request({
      hostname: 'api.anthropic.com',
      path: '/api/oauth/usage',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'anthropic-beta': 'oauth-2025-04-20',
        'Content-Type': 'application/json',
      },
      timeout: API_TIMEOUT_MS,
    }, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        if (res.statusCode === 200) {
          try { resolve(JSON.parse(data)); } catch { resolve({ error: 'parse error' }); }
        } else resolve({ error: `${res.statusCode}` });
      });
    });
    req.on('error', (e) => resolve({ error: e.code || 'network error' }));
    req.on('timeout', () => { req.destroy(); resolve({ error: 'timeout' }); });
    req.end();
  });
}

function readCache() {
  try {
    if (!existsSync(CACHE_PATH)) return null;
    return JSON.parse(readFileSync(CACHE_PATH, 'utf-8'));
  } catch { return null; }
}

function writeCache(data) {
  try {
    const dir = dirname(CACHE_PATH);
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
    writeFileSync(CACHE_PATH, JSON.stringify({ timestamp: Date.now(), ...data }));
  } catch {}
}

async function getUsageData() {
  const cache = readCache();
  if (cache) {
    const ttl = cache.apiError ? ERROR_CACHE_TTL_MS : CACHE_TTL_MS;
    const jitter = Math.random() * JITTER_MS;
    if (Date.now() - cache.timestamp < ttl + jitter) return cache;
  }

  const token = readKeychain();
  if (!token) return cache; // no credentials, use stale cache

  const resp = await fetchUsage(token);
  if (resp?.error) {
    const stale = cache || {};
    return { ...stale, timestamp: Date.now(), apiError: resp.error };
  }

  const result = {
    fiveHour: resp.five_hour?.utilization ?? null,
    fiveHourReset: resp.five_hour?.resets_at ?? null,
    sevenDay: resp.seven_day?.utilization ?? null,
    sevenDayReset: resp.seven_day?.resets_at ?? null,
    apiError: null,
  };
  writeCache(result);
  return { timestamp: Date.now(), ...result };
}

// --- Session tracking ---
function getSessionElapsed() {
  const sid = process.env.CLAUDE_SESSION_ID || 'default';
  const now = Date.now();
  let sessions = {};
  try { sessions = JSON.parse(readFileSync(SESSION_FILE, 'utf-8')); } catch {}
  if (!sessions[sid]) {
    sessions[sid] = now;
    writeFileSync(SESSION_FILE, JSON.stringify(sessions));
  }
  return now - sessions[sid];
}

// --- Stdin (context from Claude Code) ---
async function readStdin() {
  if (process.stdin.isTTY) return null;
  const chunks = [];
  process.stdin.setEncoding('utf8');
  for await (const chunk of process.stdin) chunks.push(chunk);
  const raw = chunks.join('').trim();
  if (!raw) return null;
  try { return JSON.parse(raw); } catch { return null; }
}

function getContextPercent(stdin) {
  // prefer native used_percentage
  const native = stdin?.context_window?.used_percentage;
  if (typeof native === 'number' && !isNaN(native)) {
    return Math.min(100, Math.max(0, Math.round(native)));
  }
  // fallback: manual calculation from token counts
  const size = stdin?.context_window?.context_window_size;
  if (size && size > 0) {
    const u = stdin.context_window.current_usage || {};
    const total = (u.input_tokens || 0) + (u.cache_creation_input_tokens || 0) + (u.cache_read_input_tokens || 0);
    return Math.min(100, Math.round((total / size) * 100));
  }
  return 0;
}

// --- Main ---
async function main() {
  const [usage, stdin, profileName] = await Promise.all([getUsageData(), readStdin(), getProfileName()]);
  const elapsed = getSessionElapsed();

  // context
  const ctxPct = getContextPercent(stdin);

  // 5h
  let s5;
  if (usage?.fiveHour != null) {
    const pct = Math.round(Math.min(100, Math.max(0, usage.fiveHour)));
    const reset = fmtReset(usage.fiveHourReset);
    s5 = reset
      ? `${cyan('5h:')}${color(pct)(`${pct}%`)}${gray(`(~${reset})`)}`
      : `${cyan('5h:')}${color(pct)(`${pct}%`)}`;
  } else {
    s5 = `${cyan('5h:')}${gray('--')}`;
  }

  // 7d
  let s7;
  if (usage?.sevenDay != null) {
    const pct = Math.round(Math.min(100, Math.max(0, usage.sevenDay)));
    const reset = fmtReset(usage.sevenDayReset);
    s7 = reset
      ? `${blue('7d:')}${color(pct)(`${pct}%`)}${gray(`(~${reset})`)}`
      : `${blue('7d:')}${color(pct)(`${pct}%`)}`;
  } else {
    s7 = `${blue('7d:')}${gray('--')}`;
  }

  const sCtx = `${mag('ctx:')}${color(ctxPct)(`${ctxPct}%`)}`;
  const sTime = `\x1b[37m${fmt(elapsed)}${R}`;

  const user = profileName || userInfo().username;
  const sHost = `\x1b[32m${user}\x1b[37m@\x1b[33m${hostname().replace(/\.local$/, '')}${R}`;

  const sErr = usage?.apiError ? ` ${gray('│')} ${red(`err:${usage.apiError}`)}` : '';
  console.log(`${sHost} ${gray('│')} ${s5} ${gray('│')} ${s7} ${gray('│')} ${sCtx} ${gray('│')} ${sTime}${sErr}`);
}

main().catch(() => process.exit(0));
