# require admin for symlinks
$scriptUrl = "https://raw.githubusercontent.com/luftaquila/dotfiles/main/tools/windows/install.ps1"
$origArgs = @($args)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "[INF] elevating to admin..."
  $shell = (Get-Process -Id $PID).Path
  $argString = $origArgs -join ' '
  if ($PSCommandPath) {
    Start-Process $shell -Verb RunAs -ArgumentList "-NoExit", "-File", "`"$PSCommandPath`"", $argString
  } else {
    $cmd = "& ([scriptblock]::Create((irm $scriptUrl))) $argString"
    Start-Process $shell -Verb RunAs -ArgumentList "-NoExit", "-NoProfile", "-Command", $cmd
  }
  exit
}

$ErrorActionPreference = 'Stop'

# argv
$autoInstall = ($origArgs -contains '-a') -or ($origArgs -contains '--all')


#============================================================
#  logging & ui
#============================================================
function log($level, $msg) {
  $color = switch ($level) {
    'INF' { 'Cyan' }
    'WRN' { 'Yellow' }
    'ERR' { 'Red' }
    default { 'White' }
  }
  Write-Host "[$level]" -ForegroundColor $color -NoNewline
  Write-Host " $msg"
}

function print-header($title) {
  Write-Host ''
  Write-Host $title
  Write-Host ('-' * $title.Length) -ForegroundColor DarkGray
}

function print-item($checked, $label, $indent = '') {
  Write-Host "  $indent" -NoNewline
  if ($checked) {
    Write-Host '[x]' -ForegroundColor Green -NoNewline
  } else {
    Write-Host '[ ]' -ForegroundColor DarkGray -NoNewline
  }
  Write-Host " $label"
}

function ask-yn($prompt, $default = 'y', $indent = '') {
  $hint = if ($default -eq 'n') { '(y/N)' } else { '(Y/n)' }
  while ($true) {
    Write-Host "${indent}? " -ForegroundColor Cyan -NoNewline
    Write-Host "$prompt " -NoNewline
    Write-Host $hint -ForegroundColor DarkGray -NoNewline
    Write-Host ": " -NoNewline
    $ans = Read-Host
    if ([string]::IsNullOrWhiteSpace($ans)) { $ans = $default }
    switch -Regex ($ans) {
      '^[yY]$' { return $true }
      '^[nN]$' { return $false }
      default { Write-Host "${indent}  invalid input" -ForegroundColor Yellow }
    }
  }
}


#============================================================
#  helpers
#============================================================
function link($path, $target) {
  $item = Get-Item $path -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -contains $target) {
    log INF "already linked: $path"
    return
  }
  if ($item) {
    Remove-Item $path -Recurse -Force
  }
  $dir = Split-Path $path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  New-Item -ItemType SymbolicLink -Path $path -Target $target | Out-Null
  log INF "linked: $path -> $target"
}

function wi($id) {
  winget install --accept-source-agreements --accept-package-agreements -e --id $id
  if ($LASTEXITCODE -ne 0) {
    log WRN "winget install failed for $id (exit $LASTEXITCODE) - continuing"
  }
}

function refresh-path() {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}


#============================================================
#  items
#============================================================
$sel = [ordered]@{}
foreach ($k in @('dotfiles', 'packages', 'packages-cli', 'packages-apps', 'claude', 'ssh')) {
  $sel[$k] = $false
}

function configure-items() {
  if ($autoInstall) {
    foreach ($k in @($sel.Keys)) { $sel[$k] = $true }
    return
  }

  while ($true) {
    print-header 'Installation Options'
    Write-Host ''

    $sel['dotfiles'] = ask-yn 'Dotfiles (clone + symlinks)' 'y'
    $sel['packages'] = ask-yn 'Winget packages' 'y'

    if ($sel['packages']) {
      Write-Host '  packages:' -ForegroundColor DarkGray
      $sel['packages-cli']  = ask-yn 'CLI tools (PowerShell, Starship, NerdFont, Neovim, ...)' 'y' '    '
      $sel['packages-apps'] = ask-yn 'Apps (Fork, PowerToys, WireGuard, KakaoTalk)'             'y' '    '
    }

    $sel['claude'] = ask-yn 'Claude Code' 'y'
    if ($sel['claude'] -and -not $sel['dotfiles']) {
      Write-Host '      ! Claude config requires dotfiles - auto-enabling dotfiles' -ForegroundColor Yellow
      $sel['dotfiles'] = $true
    }

    $sel['ssh'] = ask-yn 'SSH setup (authorized_keys + key gen)' 'y'

    print-header 'Summary'
    print-item $sel['dotfiles']      'Dotfiles'
    print-item $sel['packages']      'Winget packages'
    if ($sel['packages']) {
      print-item $sel['packages-cli']  'CLI tools' '  '
      print-item $sel['packages-apps'] 'Apps'      '  '
    }
    print-item $sel['claude']        'Claude Code'
    print-item $sel['ssh']           'SSH setup'
    Write-Host ''

    $edit = $false
    while (-not $edit) {
      Write-Host '? ' -ForegroundColor Cyan -NoNewline
      Write-Host '[' -NoNewline
      Write-Host 'c' -ForegroundColor Green -NoNewline
      Write-Host ']ontinue / [' -NoNewline
      Write-Host 'e' -ForegroundColor Yellow -NoNewline
      Write-Host ']dit / [' -NoNewline
      Write-Host 'a' -ForegroundColor Red -NoNewline
      Write-Host ']bort: ' -NoNewline
      $action = Read-Host
      if ([string]::IsNullOrWhiteSpace($action)) { $action = 'c' }
      switch -Regex ($action) {
        '^[cC]$' { return }
        '^[eE]$' { $edit = $true }
        '^[aA]$' { log INF 'aborting.'; exit 0 }
        default { Write-Host '  invalid input' -ForegroundColor Yellow }
      }
    }
  }
}


#============================================================
#  install: dotfiles
#============================================================
function install-dotfiles() {
  log INF 'setting up dotfiles...'

  $dir = "$HOME\dotfiles"
  if (Test-Path $dir) {
    $remotes = (git -C $dir remote -v) -join "`n"
    if ($remotes -notmatch 'luftaquila/dotfiles') {
      log ERR 'existing dotfiles directory is not from luftaquila/dotfiles. terminating.'
      exit 1
    }
    log INF 'existing dotfiles directory found'
    git -C $dir fetch origin
    $local = (git -C $dir rev-parse HEAD).Trim()
    $upstream = (git -C $dir rev-parse '@{u}').Trim()
    if ($local -ne $upstream) {
      log INF 'updating dotfiles...'
      git -C $dir pull origin main
      if ($LASTEXITCODE -ne 0) {
        log ERR 'cannot update dotfiles due to conflict. terminating.'
        exit 1
      }
      log INF 'installation script updated. restarting...'
      & "$dir\tools\windows\install.ps1" @origArgs
      exit 0
    }
  } else {
    log INF 'cloning dotfiles...'
    git clone https://github.com/luftaquila/dotfiles.git $dir
    if ($LASTEXITCODE -ne 0) {
      log ERR 'failed to clone dotfiles. terminating.'
      exit 1
    }
  }

  # symlinks (both PowerShell 5.1 and 7 profile paths)
  $profileSrc = "$dir\tools\windows\Microsoft.PowerShell_profile.ps1"
  foreach ($p in @(
    "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  )) {
    link $p $profileSrc
  }

  link "$HOME\.gitconfig" "$dir\.gitconfig"
  link "$HOME\AppData\Local\nvim" "$dir\nvim"
}


#============================================================
#  install: packages
#============================================================
function install-packages-cli() {
  log INF 'installing CLI packages...'
  # shell & terminal
  wi Microsoft.PowerShell
  wi Starship.Starship
  wi DEVCOM.JetBrainsMonoNerdFont
  # editor
  wi Neovim.Neovim
  # cli tools
  wi ajeetdsouza.zoxide
  wi dandavison.delta
  wi BurntSushi.ripgrep.MSVC
  wi eza-community.eza
  wi junegunn.fzf
  wi ezwinports.make
  wi BrechtSanders.WinLibs.POSIX.UCRT
  # runtimes
  wi OpenJS.NodeJS.LTS
  wi Python.Python.3.14

  # refresh PATH so nvim/make/gcc are visible for plugin build
  refresh-path

  # sync nvim plugins (needs nvim config from dotfiles + make + gcc for native builds)
  if ((Test-Path "$HOME\AppData\Local\nvim") -and (Get-Command nvim -ErrorAction SilentlyContinue)) {
    log INF 'syncing nvim plugins (Lazy)...'
    nvim --headless '+Lazy! sync' +qall
    if ($LASTEXITCODE -ne 0) {
      log WRN "nvim plugin sync failed (exit $LASTEXITCODE) - run ':Lazy sync' manually"
    }
  }
}

function install-packages-apps() {
  log INF 'installing applications...'
  wi Fork.Fork
  wi Microsoft.PowerToys
  wi WireGuard.WireGuard
  wi Kakao.KakaoTalk
}


#============================================================
#  install: claude
#============================================================
function install-claude() {
  if (Get-Command claude -ErrorAction SilentlyContinue) {
    log INF 'Claude Code is already installed. skipping install...'
  } else {
    log INF 'installing Claude Code...'
    irm https://claude.ai/install.ps1 | iex

    # persist ~/.local/bin in user PATH
    $localBin = "$HOME\.local\bin"
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$localBin*") {
      log INF "adding $localBin to user PATH..."
      [Environment]::SetEnvironmentVariable("Path", "$userPath;$localBin", "User")
    }
    $env:Path = "$env:Path;$localBin"
  }

  # plugin commands may fail if already present - tolerate
  try { claude plugin marketplace add https://github.com/wakatime/claude-code-wakatime.git } catch { log WRN "marketplace add failed - continuing" }
  try { claude plugin i claude-code-wakatime@wakatime } catch { log WRN "plugin install failed - continuing" }

  log INF 'configuring Claude Code...'
  foreach ($f in @("settings.json", "hud\status.mjs")) {
    link "$HOME\.claude\$f" "$HOME\dotfiles\tools\claude\$f"
  }
}


#============================================================
#  install: ssh
#============================================================
function install-authorized-keys() {
  # Windows OpenSSH: admin users use administrators_authorized_keys by default
  $adminKeys = "$env:ProgramData\ssh\administrators_authorized_keys"
  $dir = Split-Path $adminKeys
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  log INF "installing authorized_keys to $adminKeys..."
  try {
    Invoke-WebRequest -Uri 'https://github.com/luftaquila.keys' -OutFile $adminKeys -UseBasicParsing
  } catch {
    log WRN "failed to fetch luftaquila.keys - skipping"
    return
  }

  # restrict ACL (required by sshd for admin keys)
  icacls $adminKeys /inheritance:r | Out-Null
  icacls $adminKeys /grant 'Administrators:F' 'SYSTEM:F' | Out-Null
}

function generate-ssh-key() {
  $pubkey = "$HOME\.ssh\id_ed25519"
  if (-not (Test-Path "$pubkey.pub")) {
    log INF 'no ssh key found! generating new one...'
    if (-not (Test-Path "$HOME\.ssh")) {
      New-Item -ItemType Directory -Path "$HOME\.ssh" -Force | Out-Null
    }
    ssh-keygen -t ed25519 -f $pubkey -N '""' -q
  }

  $pub = Get-Content "$pubkey.pub"
  log INF "ssh key: $pub"
  log INF 'assign this key to GitHub at https://github.com/settings/keys'

  if ((Test-Path "$HOME\dotfiles") -and (ask-yn 'Replace dotfile remote url from https to ssh?' 'y')) {
    git -C "$HOME\dotfiles" remote set-url origin git@github.com:luftaquila/dotfiles.git
  }
}

function install-ssh() {
  install-authorized-keys
  generate-ssh-key
}


#============================================================
#  execute
#============================================================
function execute-items() {
  if ($sel['dotfiles'])       { install-dotfiles }
  if ($sel['packages']) {
    if ($sel['packages-cli'])  { install-packages-cli }
    if ($sel['packages-apps']) { install-packages-apps }
  }
  if ($sel['claude'])         { install-claude }
  if ($sel['ssh'])            { install-ssh }
}


#============================================================
#  launch
#============================================================

# install git first (needed for clone + fetch/pull)
log INF 'ensuring Git is installed...'
wi Git.Git
refresh-path

configure-items
execute-items

log INF 'ALL DONE!'
