# set aliases
function gad { git add }
function gap { git add -p }

function gck { git checkout }
function gcb { git checkout -b }

del alias:gcm -Force
function gcm { git commit --verbose }
function gca { git commit --verbose --amend }

function gdf { git diff }
function gds { git diff --staged }
# Set-Alias -Name gdo

function gfh { git fetch }

function glg { git log --graph }
function glo { git log --oneline }

function gpl { git pull }
function gpr { git pull --rebase }

function gph { git push }
function gpf { git push -f }

function grt { git reset }
function grh { git reset HEAD^ }
function grm { git reset --merge }
function gro { git reset --hard "@{u}" }

function grr { git restore }
function grs { git restore --staged }

function gsh { git stash }
function gsp { git stash pop }
function gsd { git stash drop }
function gsl { git stash list -p }
function gss { git stash show -p }

function gst { git status }

Set-Alias -Name vi -Value nvim

Set-PSReadlineKeyHandler -Key Tab -Function Complete

oh-my-posh init pwsh --config $env:POSH_THEMES_PATH/powerlevel10k_lean.omp.json | Invoke-Expression
