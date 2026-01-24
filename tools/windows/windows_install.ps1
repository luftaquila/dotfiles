# clone dotfiles
cd "$HOME"
git clone https://github.com/luftaquila/dotfiles.git

# install powershell profile
Remove-Item "$profile"
New-Item -ItemType SymbolicLink -Path "$profile" -Target "$HOME\dotfiles\MicroSoft.PowerShell_profile.ps1"

# install per-machine powershell script
"# per-machine setup" > "$HOME"

# install .gitconfig
Remove-Item "$HOME\.gitconfig"
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$HOME\dotfiles\.gitconfig"

# install nvim
New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Local\nvim" -Target "$HOME\dotfiles\nvim"

# install packages
winget install dandavison.delta
winget install ajeetdsouza.zoxide
winget install JanDeDobbeleer.OhMyPosh
winget install Neovim.Neovim

# oh my posh theme
curl https://raw.githubusercontent.com/Kudostoy0u/pwsh10k/master/pwsh10k.omp.json --output $env:POSH_THEMES_PATH/pwsh10k.omp.json
