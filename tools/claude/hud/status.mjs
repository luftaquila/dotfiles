#!/usr/bin/env node
import { readFileSync, writeFileSync, existsSync, mkdirSync, renameSync } from 'fs';
import { join, dirname } from 'path';
import { execFileSync } from 'child_process';
import { tmpdir, homedir, userInfo, hostname } from 'os';
import { createHash } from 'crypto';
import https from 'https';

const PROFILE_CACHE_PATH = join(homedir(), '.claude', 'hud', '.profile-cache.json');
const SESSION_FILE = join(tmpdir(), 'claude-hud-sessions.json');
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

function fmtReset(epochSec) {
  if (!epochSec) return null;
  const diff = epochSec * 1000 - Date.now();
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

function atomicWrite(filePath, data) {
  const dir = dirname(filePath);
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
  const tmp = filePath + `.tmp.${process.pid}`;
  writeFileSync(tmp, data);
  renameSync(tmp, filePath);
}

async function getProfileName() {
  const token = readKeychain();
  if (!token) return null;
  const tokenHash = createHash('sha256').update(token).digest('hex').slice(0, 16);

  // cache is keyed by token hash so switching accounts invalidates it
  try {
    if (existsSync(PROFILE_CACHE_PATH)) {
      const cache = JSON.parse(readFileSync(PROFILE_CACHE_PATH, 'utf-8'));
      if (cache.name && cache.tokenHash === tokenHash &&
          Date.now() - cache.timestamp < PROFILE_CACHE_TTL_MS)
        return cache.name;
    }
  } catch {}

  const resp = await fetchProfile(token);
  const name = resp?.account?.display_name || resp?.account?.full_name || null;
  if (name) {
    try {
      atomicWrite(PROFILE_CACHE_PATH, JSON.stringify({ timestamp: Date.now(), tokenHash, name }));
    } catch {}
  }
  return name;
}

// --- Session tracking ---
const SESSION_TTL_MS = 86_400_000; // drop session records older than 24h

function getSessionElapsed(sid) {
  if (!sid) return 0;
  const now = Date.now();
  let sessions = {};
  try { sessions = JSON.parse(readFileSync(SESSION_FILE, 'utf-8')); } catch {}
  const cutoff = now - SESSION_TTL_MS;
  let dirty = false;
  for (const k of Object.keys(sessions)) {
    if (sessions[k] < cutoff) { delete sessions[k]; dirty = true; }
  }
  if (!sessions[sid]) { sessions[sid] = now; dirty = true; }
  if (dirty) {
    try { writeFileSync(SESSION_FILE, JSON.stringify(sessions)); } catch {}
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
  const [stdin, profileName] = await Promise.all([readStdin(), getProfileName()]);
  const elapsed = getSessionElapsed(stdin?.session_id);

  // rate limits from stdin (provided by Claude Code)
  const fiveHour = stdin?.rate_limits?.five_hour;
  const sevenDay = stdin?.rate_limits?.seven_day;

  // context
  const ctxPct = getContextPercent(stdin);

  // 5h
  let s5;
  if (fiveHour?.used_percentage != null) {
    const pct = Math.round(Math.min(100, Math.max(0, fiveHour.used_percentage)));
    const reset = fmtReset(fiveHour.resets_at);
    s5 = reset
      ? `${cyan('5h:')}${color(pct)(`${pct}%`)}${gray(`(~${reset})`)}`
      : `${cyan('5h:')}${color(pct)(`${pct}%`)}`;
  } else {
    s5 = `${cyan('5h:')}${gray('--')}`;
  }

  // 7d
  let s7;
  if (sevenDay?.used_percentage != null) {
    const pct = Math.round(Math.min(100, Math.max(0, sevenDay.used_percentage)));
    const reset = fmtReset(sevenDay.resets_at);
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

  console.log(`${sHost} ${gray('│')} ${s5} ${gray('│')} ${s7} ${gray('│')} ${sCtx} ${gray('│')} ${sTime}`);
}

main().catch(() => process.exit(0));
