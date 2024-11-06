# clone dotfiles
cd "$HOME"
git clone git@github.com:luftaquila/dotfiles.git

# install powershell profile
Remove-Item "$profile"
New-Item -ItemType SymbolicLink -Path "$profile" -Target "$HOME\dotfiles\MicroSoft.PowerShell_profile.ps1"

# install .gitconfig
Remove-Item "$HOME\.gitconfig"
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$HOME\dotfiles\.gitconfig"

# install nvim
New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Local\nvim" -Target "$HOME\dotfiles\nvim"
