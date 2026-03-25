# clone dotfiles
if (-not (Test-Path "$HOME\dotfiles")) {
  git clone https://github.com/luftaquila/dotfiles.git "$HOME\dotfiles"
}

# install powershell profile
$profileDir = Split-Path "$profile"
if (-not (Test-Path $profileDir)) {
  New-Item -ItemType Directory -Path $profileDir -Force
}
Remove-Item "$profile" -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path "$profile" -Target "$HOME\dotfiles\tools\windows\MicroSoft.PowerShell_profile.ps1"

# install .gitconfig
Remove-Item "$HOME\.gitconfig" -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$HOME\dotfiles\.gitconfig"

# install nvim
if (-not (Test-Path "$HOME\AppData\Local\nvim")) {
  New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Local\nvim" -Target "$HOME\dotfiles\nvim"
}

# install packages
winget install Starship.Starship
winget install Neovim.Neovim
winget install dandavison.delta
winget install ajeetdsouza.zoxide
Install-Module -Name PowerShellGet -Force
