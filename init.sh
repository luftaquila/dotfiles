#!/bin/bash

###############################################################################
#  stage definitions
###############################################################################
stages=( "system packages" "Rust" "NeoVim" "Oh My Zsh" "dotfiles" )
stages_function=(
  fn_install_system_packages
  fn_install_rust
  fn_install_neovim
  fn_install_ohmyzsh
  fn_install_dotfiles
)
stages_confirm=( true true true true true )


################################################################################
#  detect OS
################################################################################
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  platform='linux'
  package_cmd='sudo apt-get'
  openssh_name='openssh-client'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  platform='macos'
  package_cmd='brew'
  openssh_name='openssh'
else
  echo "[ERR] unknown OS detected! terminating..."
  exit 1
fi

echo "[INF] target OS: $platform"


################################################################################
#  functions
################################################################################
function fn_cmd() {
  echo "[CMD] $1"
  eval $1

  if [[ "$?" -ne 0 ]]; then
    echo "[ERR] command failed."
    if ! [[ $2 == "ignore" ]]; then
      echo "[INF] terminating..."
      exit 1
    fi
  fi
}

function fn_install_system_packages() {
  echo "[INF] installing system packages..."

  common_packages=(
    "bat" "curl" "htop" "ripgrep" "thefuck" "tmux" "universal-ctags" "wget"
  )
  linux_packages=( "build-essential" "cmake" "fd-find" "libncurses-dev" )
  macos_packages=( "fd" )

  fn_cmd "$package_cmd update && $package_cmd upgrade"
  fn_cmd "$package_cmd install ${common_packages[*]}"

  if [[ $platform == "linux" ]]; then
    fn_cmd "$package_cmd install ${linux_packages[*]}"

    echo "[INF] creating executable symbolic links..."

    fn_cmd "mkdir -p $HOME/.local/bin"
    fn_cmd "ln -s $(which fdfind) ~/.local/bin/fd"
    fn_cmd "ln -s $(which batcat) ~/.local/bin/bat"
  elif [[ $platform == "macos" ]]; then
    fn_cmd "$package_cmd install ${macos_packages[*]}"
  fi
}

function fn_install_rust() {
  echo "[INF] installing Rust..."

  rust_packages=( "eza" "du-dust" "git-delta" )

  fn_cmd "curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh"
  fn_cmd "source $HOME/.cargo/env"

  echo "[INF] installing Rust Cargo crates..."

  fn_cmd "cargo install ${rust_packages[*]}"
}

function fn_install_neovim() {
  echo "[INF] installing NeoVim..."

  if [[ $platform == "linux" ]]; then
    fn_cmd "$package_cmd install fuse3 libfuse2"
    fn_cmd "wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
    fn_cmd "mv nvim.appimage ~/.local/bin/nvim && chmod 744 ~/.local/bin/nvim"
    fn_cmd 'PATH="$HOME/.local/bin:$PATH"'
    fn_cmd "$package_cmd install python3-neovim"
  elif [[ $platform == "macos" ]]; then
    fn_cmd "$package_cmd install neovim"
    fn_cmd "pip3 install pynvim"
  fi

  fn_cmd "mkdir -p ~/.config"
  fn_cmd "cp -r nvim ~/.config"

  fn_cmd "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
  fn_cmd "nvim -Es -u ~/.config/nvim/init.vim +PluginInstall +qall" ignore
}

function fn_install_ohmyzsh() {
  echo "[INF] installing Oh My Zsh..."

  if ! [[ -x "$(command -v zsh)" ]]; then
    echo "[WRN] no zsh detected! installing it first..."
    fn_cmd "$package_cmd install zsh"
  fi

  fn_cmd "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"
  fn_cmd "chsh -s `which zsh`"

  echo "[INF] installing zsh plugins..."

  ZSH_CUSTOM=`zsh -ic 'echo $ZSH_CUSTOM'`
  fn_cmd "zsh -c 'git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k'"
  fn_cmd "zsh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting'"

  echo "[INF] installing powerlevel10k..."

  fn_cmd "zsh -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'"
}

function fn_install_dotfiles() {
  echo "[INF] installing dotfiles..."

  backups=( ".gitconfig" ".zshrc" ".machine.zsh" ".p10k.zsh" ".tmux.conf" )

  fn_cmd "rm -rf backups && mkdir backups"

  for obj in "${backups[@]}"; do
    if [[ -f ~/$obj ]]; then
      fn_cmd "cp ~/$obj ./backups/$obj"
      fn_cmd "rm -f ~/$obj"
    fi
    fn_cmd "ln -s `pwd`/$obj ~/$obj"
  done
}


################################################################################
#  check git installation
################################################################################
if ! [[ -x "$(command -v git)" ]]; then
  echo "[ERR] no git detected!"

  while true; do
    input=''
    read -p "  install git? (Y/n): " input
    if [ -z $input ] || [ $input == 'y' ] || [ $input == 'Y' ]; then
      echo "[INF] installing git..."
      fn_cmd "$package_cmd update"
      fn_cmd "$package_cmd install git"
      break
    elif [ $input == 'n' ] || [ $input == 'N' ]; then
      echo "[WRN] git is required to proceed. terminating."
      exit 1
      break
    else
      echo "    invalid input"
    fi
  done
fi


################################################################################
#  identify dotfiles repository
################################################################################
echo "[INF] looking for dotfiles..."
if ! `git remote -v | grep -q 'git@github.com:luftaquila/dotfiles'`; then
  # check ssh client
  if ! [[ -x "$(command -v ssh)" ]]; then
    echo "[ERR] no ssh client detected!"

    while true; do
      input=''
      read -p "  install openssh? (Y/n): " input
      if [ -z $input ] || [ $input == 'y' ] || [ $input == 'Y' ]; then
        echo "[INF] installing openssh..."
        fn_cmd "$package_cmd install $openssh_name"
        break
      elif [ $input == 'n' ] || [ $input == 'N' ]; then
        echo "[WRN] ssh client is required to proceed. terminating."
        exit 1
        break
      else
        echo "    invalid input"
      fi
    done
  fi

  # check ssh key
  ssh_pubkey=~/.ssh/id_ed25519
  if ! [[ -f $ssh_pubkey ]]; then
    echo "[INF] no ssh key found! generating new..."
    fn_cmd "ssh-keygen -t ed25519 -f $ssh_pubkey -N '' <<< y"
  fi
  echo "[INF] ssh key: `cat $ssh_pubkey.pub`"
  echo "[INF] assign the key at https://github.com/settings/keys"
  read -p "  Press ENTER to continue..."

  # cloning dotfiles
  echo "[INF] cloning dotfiles..."
  fn_cmd "git clone git@github.com:luftaquila/dotfiles.git ~/dotfiles"
  fn_cmd "cd ~/dotfiles"

  echo "[INF] restarting in cloned directory..."
  exec ./init.sh
fi


################################################################################
#  configure stages
################################################################################
echo "[INF] configuring stages..."

for i in `seq 0 $(( ${#stages[@]} - 1 ))`; do
  while true; do
    input=''
    read -p "  install ${stages[$i]}? (Y/n): " input
    if [ -z $input ] || [ $input == 'y' ] || [ $input == 'Y' ]; then
      stages_confirm[$i]=true
      break
    elif [ $input == 'n' ] || [ $input == 'N' ]; then
      stages_confirm[$i]=false
      break
    else
      echo "    invalid input"
    fi
  done
done

echo "[INF] please confirm the configurations:"

for i in `seq 0 $(( ${#stages[@]} - 1 ))`; do
  echo "  install ${stages[$i]}...${stages_confirm[$i]}"
done
read -p "  Press ENTER to continue..."


################################################################################
#  execute stages
################################################################################
for i in `seq 0 $(( ${#stages[@]} - 1 ))`; do
  if [[ ${stages_confirm[$i]} == true ]]; then
    eval ${stages_function[$i]}
  fi
done

