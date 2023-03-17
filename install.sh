#!/bin/bash

packages=(
  "curl"
  "bat"
  "git"
  "htop"
  "ripgrep"
  "thefuck"
  "tmux"
  "zsh"
)
rust_packages=(
  "git-delta"
  "du-dust"
  "tealdeer"
)

backups=(
  ".gitconfig"
  ".p10k.zsh"
  ".tmux.conf"
  ".zshrc"
  ".vimrc"
)

if [ -e $1 ] || [ $1 != "skipinstall" ]; then
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

  # install Oh My Zsh
  printf '\n\n####################################\n'
  printf 'installing oh my zsh...'
  printf '\n####################################\n\n'

  echo "rm -rf ~/.oh-my-zsh"
  rm -rf ~/.oh-my-zsh

  echo "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"
  curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

  echo "chsh -s `which zsh`"
  chsh -s `which zsh`


  # install powerlevel10k
  printf '\n\n####################################\n'
  printf 'installing powerlevel10k...'
  printf '\n####################################\n\n'

  echo "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


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

echo "cd .."
cd ..


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

for obj in "${backups[@]}"
do
  echo "ln -s `pwd`/$obj ~/$obj"
  ln -s `pwd`/$obj ~/$obj
done


# configure vim
printf '\n\n####################################\n'
printf 'configuring VIM...'
printf '\n####################################\n\n'

echo "rm -rf ~/.vim"
rm -rf ~/.vim

echo "cp -r ./.vim ~"
cp -r ./.vim ~

echo "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "vim -E -s -u ~/.vimrc +VundleInstall +qall"
vim -E -s -u ~/.vimrc +VundleInstall +qall
