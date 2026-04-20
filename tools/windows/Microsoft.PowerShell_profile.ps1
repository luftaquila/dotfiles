# set terminal locale
$env:LANG="en"
$env:LANGUAGE="en"
$env:LC_MESSAGES="C"

# force UTF-8 so starship's unicode glyphs render correctly
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

$env:STARSHIP_CONFIG = "$HOME\dotfiles\tools\starship\starship.toml"
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell --cmd j | Out-String) })

# starship init doesn't render right_format on PowerShell; override prompt to compose it
function global:prompt {
    $origDollarQuestion = $global:?
    $origLastExitCode = $global:LASTEXITCODE

    try { if (Test-Path function:Invoke-Starship-PreCommand) { Invoke-Starship-PreCommand } } catch {}

    $jobs = @(Get-Job | Where-Object { $_.State -eq 'Running' }).Count
    $cwd = Get-Location
    $width = $Host.UI.RawUI.WindowSize.Width

    $sArgs = @(
        'prompt',
        "--path=$($cwd.ProviderPath)",
        "--logical-path=$($cwd.Path)",
        "--terminal-width=$width",
        "--jobs=$jobs"
    )

    $exitForPrompt = 0
    if ($lastCmd = Get-History -Count 1) {
        if (-not $origDollarQuestion) {
            $lastCmdletError = try { $global:error[0] | Where-Object { $_ -ne $null } | Select-Object -ExpandProperty InvocationInfo } catch { $null }
            $exitForPrompt = if ($null -ne $lastCmdletError -and $lastCmd.CommandLine -eq $lastCmdletError.Line) { 1 } else { $origLastExitCode }
        }
        $duration = [math]::Round(($lastCmd.EndExecutionTime - $lastCmd.StartExecutionTime).TotalMilliseconds)
        $sArgs += "--cmd-duration=$duration"
    }
    $sArgs += "--status=$exitForPrompt"

    if ([Microsoft.PowerShell.PSConsoleReadLine]::InViCommandMode()) { $sArgs += '--keymap=vi' }

    $left  = ((& starship @sArgs)         -join '') -replace "`r?`n$", ''
    $right = ((& starship @sArgs --right) -join '') -replace "`r?`n$", ''
    $right = $right.TrimEnd()

    $ansi = [regex]'\x1b\[[0-9;?]*[a-zA-Z]|\x1b\].*?(\x07|\x1b\\)'
    $leftLen  = $ansi.Replace($left,  '').Length
    $rightLen = $ansi.Replace($right, '').Length

    $pad = $width - $leftLen - $rightLen

    # write right prompt as console side-effect so it stays outside PSReadLine's
    # buffered prompt string; avoids re-emitting `e7...`e8 on every redraw (tab, menu, predictions).
    if ($rightLen -gt 0 -and $pad -ge 1) {
        [Console]::Write("`e7`e[$($width - $rightLen + 1)G$right`e8")
    }

    Set-PSReadLineOption -ExtraPromptLineCount 0
    $left

    $global:LASTEXITCODE = $origLastExitCode
    if ($global:? -ne $origDollarQuestion) {
        if ($origDollarQuestion) { 1+1 } else { Write-Error '' -ErrorAction 'Ignore' }
    }
}

# autocomplete
Set-PSReadlineOption -EditMode Vi
Set-PSReadlineOption -PredictionSource History
Set-PSReadlineOption -PredictionViewStyle InlineView

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# set aliases
Set-Alias -Name vi -Value nvim

function c  { clear }
function py { python @args }

function make { make.exe -j @args }

function cl  { claude --remote-control @args }
function cld { claude --dangerously-skip-permissions --remote-control @args }

function gad { git add $args }
function gap { git add -p $args }

function gck { git checkout $args }
function gcb { git checkout -b $args }

del alias:gcm -Force
function gcm { git commit --verbose $args }
function gca { git commit --verbose --amend $args }

function gcp { git cherry-pick @args }

function gdf { git diff $args }
function gds { git diff --staged $args }
function gdu { git diff '@{u}' @args }

function gdo {
    param([string]$Branch)

    if ([string]::IsNullOrEmpty($Branch)) {
        $files = git diff --name-only
        if (-not $files) { Write-Error 'no diff found!'; return }
        $root = (git rev-parse --show-toplevel).Trim()
        $paths = $files | ForEach-Object { Join-Path $root $_ }
        $paths | ForEach-Object { Write-Host $_ }
        & nvim @paths
    } else {
        $files = git diff --merge-base $Branch --name-only
        if (-not $files) { Write-Error 'no diff found!'; return }
        $root = (git rev-parse --show-toplevel).Trim()
        $paths = $files | ForEach-Object { Join-Path $root $_ }
        & nvim "+Gitsigns change_base $Branch true" @paths
    }
}

function gfh { git fetch $args }

function glg { git log --graph $args }
function glo { git log --oneline $args }

function gpl { git pull $args }
function gpr { git pull --rebase $args }

function gph { git push $args }
function gpf { git push -f $args }
function gpn { git push --set-upstream origin "$(git branch --show-current)" @args }

function grt { git reset $args }
function grh { git reset HEAD^ $args }
function grm { git reset --merge $args }
function gro { git reset --hard '@{u}' @args }

function grr { git restore $args }
function grs { git restore --staged $args }

function gsh { git stash $args }
function gsp { git stash pop $args }
function gsd { git stash drop $args }
function gsl { git stash list -p $args }
function gss { git stash show -p $args }

function gst { git status $args }

function gbs { git bisect start @args }
function gbb { git bisect bad @args }
function gbg { git bisect good @args }
function gbr { git bisect reset @args }

function rgh { rg --hidden --no-ignore --smart-case @args }

del alias:rm -Force -ErrorAction SilentlyContinue
function rm {
    $recurse = $false
    $force = $false
    $paths = [System.Collections.Generic.List[string]]::new()
    foreach ($a in $args) {
        if ($a -match '^-[rRfF]+$') {
            if ($a -cmatch '[rR]') { $recurse = $true }
            if ($a -cmatch '[fF]') { $force = $true }
        } else {
            $paths.Add($a)
        }
    }
    if ($paths.Count -eq 0) { Write-Error 'rm: missing operand'; return }
    $p = @{}
    if ($recurse) { $p.Recurse = $true }
    if ($force)   { $p.Force = $true; $p.ErrorAction = 'SilentlyContinue' }
    Remove-Item @p -Path $paths
}

del alias:ls -Force -ErrorAction SilentlyContinue
function ls { eza --color-scale --time-style long-iso @args }
function ll { eza --color-scale --time-style long-iso --long @args }
function la { eza --color-scale --time-style long-iso --group --long --all @args }
function lf { eza --color-scale --time-style long-iso --group --long --all --total-size @args }