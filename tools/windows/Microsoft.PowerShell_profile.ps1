# set terminal locale
$env:LANG="en"
$env:LANGUAGE="en"
$env:LC_MESSAGES="C"

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# autocomplete
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# set aliases
Set-Alias -Name vi -Value nvim

function gad { git add $args }
function gap { git add -p $args }

function gck { git checkout $args }
function gcb { git checkout -b $args }

del alias:gcm -Force
function gcm { git commit --verbose $args }
function gca { git commit --verbose --amend $args }

function gdf { git diff $args }
function gds { git diff --staged $args }
# Set-Alias -Name gdo

function gfh { git fetch $args }

function glg { git log --graph $args }
function glo { git log --oneline $args }

function gpl { git pull $args }
function gpr { git pull --rebase $args }

function gph { git push $args }
function gpf { git push -f $args }

function grt { git reset $args }
function grh { git reset HEAD^ $args }
function grm { git reset --merge $args }
function gro { git reset --hard "@{u$args }" }

function grr { git restore $args }
function grs { git restore --staged $args }

function gsh { git stash $args }
function gsp { git stash pop $args }
function gsd { git stash drop $args }
function gsl { git stash list -p $args }
function gss { git stash show -p $args }

function gst { git status $args }