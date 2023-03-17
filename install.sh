#!/bin/bash

packages=(
  "bat"
  "ctags"
  "dust"
  "git"
  "htop"
  "powerline-go"
  "ripgrep"
  "thefuck"
  "tmux"
)
rust_packages=("git-delta")

backups=(
  ".gitconfig"
  ".tmux.conf"
  ".zshrc"
  ".bashrc"
  ".vimrc"
)

if [ $1 != "skipinstall" ]; then
  # install packages
  read -p "os(linux/mac): " os

  printf '\n####################################\n'
  printf 'installing packages...'
  printf '\n####################################\n\n'

  if [ $os == 'linux' ]; then
    read -p "system package manager: " packmgr
    echo "sudo $packmgr install ${packages[*]}"
    sudo $packmgr install ${packages[*]}

  elif [ $os == 'mac' ]; then
    echo "brew install ${packages[*]}"
    brew install ${packages[*]}

  else
    printf "unknown os $os!\n"
    exit -1
  fi

  # install RUST
  printf '\n\n####################################\n'
  printf 'installing rust...'
  printf '\n####################################\n\n'
  echo "curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh"
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh


  # install cargo packages
  printf '\n\n####################################\n'
  printf 'installing rust packages...'
  printf '\n####################################\n\n'
  echo "cargo install ${rust_packages[*]}"
  cargo install ${rust_packages[*]}
fi


# create backups
printf '\n\n####################################\n'
printf 'creating backups...'
printf '\n####################################\n\n'

echo 'mkdir backups'
mkdir backups

echo 'cd backups'
cd backups

for obj in "${backups[@]}"
do
  echo "cp ~/$obj ./$obj"
  cp ~/$obj ./$obj
done


# remove target
printf '\n\n####################################\n'
printf 'removing targets...'
printf '\n####################################\n\n'

for obj in "${backups[@]}"
do
  echo "rm ~/$obj"
  rm ~/$obj
done


# generate symlinks to target
printf '\n\n####################################\n'
printf 'generating symlinks to target...'
printf '\n####################################\n\n'

echo "cd .."
cd ..
dir=`pwd`

for obj in "${backups[@]}"
do
  echo "ln -s $dir/$obj ~/$obj"
  ln -s $dir/$obj ~/$obj
done
