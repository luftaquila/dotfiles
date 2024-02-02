#!/bin/bash

common_packages=(
  "curl" "bat" "eza" "htop" "ripgrep" "thefuck"
  "tmux" "universal-ctags" "zsh"
)
linux_packages=( "cmake" "fd-find" "libncurses-dev" )
macos_packages=( "fd" )
rust_packages=( "git-delta" "du-dust" )

backups=( ".gitconfig" ".p10k.zsh" ".tmux.conf" ".zshrc" ".vimrc" )

stages=(
  "system packages"
  "Oh My Zsh"
  "Rust"
  "dotfiles"
  "NeoVim"
)

stages_function=(
  fn_install_system_packages
  fn_install_ohmyzsh
  fn_install_rust
  fn_install_dotfiles
  fn_install_neovim
)

stages_confirm=( true true true true true )

function fn_cmd() {
  echo "[CMD] $1"
  eval $1

  if [[ "$?" -ne 0 ]]; then
    echo "[ERR]: command failed. terminating..."
    exit 1
  fi
}

#########################################################
#  detect OS
#########################################################
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

#########################################################
#  check git installation
#########################################################
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

#########################################################
#  identify dotfiles repository
#########################################################
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
  fn_cmd "git clone git@github.com:luftaquila/dotfiles.git"
  fn_cmd "cd dotfiles"

  echo "[INF] restarting in cloned directory..."
  exec ./init.sh
fi

#########################################################
#  configure stages
#########################################################
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

#########################################################
#  do installation stages
#########################################################

