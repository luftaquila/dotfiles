#!/bin/bash

linux_packages=(
  "curl"
  "bat"
  "fd-find"
  "git"
  "htop"
  "ripgrep"
  "thefuck"
  "tmux"
  "zsh"
)

macos_packages=(
  "curl"
  "bat"
  "fd"
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

# install packages
printf '\n\n'
read -p "install system packages? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n####################################\n'
  printf 'installing packages...'
  printf '\n####################################\n\n'

  read -p "os(linux/mac): " os

  if [ $os == 'linux' ]; then
    echo "sudo apt-get install ${linux_packages[*]}"
    sudo apt-get install ${linux_packages[*]}

  elif [ $os == 'mac' ]; then
    echo "brew install ${macos_packages[*]}"
    brew install ${macos_packages[*]}

  else
    printf "unknown os $os!\n"
    exit -1
  fi
fi


# create symbolic links
printf '\n\n'
read -p "create symbolic links? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n\n####################################\n'
  printf 'creating symbolic links...'
  printf '\n####################################\n\n'

  if [ $os == 'linux' ]; then
    # fd
    echo "ln -s $(which fdfind) ~/.local/bin/fd"
    ln -s $(which fdfind) ~/.local/bin/fd

    # bat
    echo "ln -s $(which batcat) ~/.local/bin/bat"
    ln -s $(which batcat) ~/.local/bin/bat

  elif [ $os == 'mac' ]; then
  fi
fi


# install Oh My Zsh
printf '\n\n'
read -p "install Oh My Zsh? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n\n####################################\n'
  printf 'installing oh my zsh...'
  printf '\n####################################\n\n'

  echo "rm -rf ~/.oh-my-zsh"
  rm -rf ~/.oh-my-zsh

  echo "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"
  curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

  echo "chsh -s `which zsh`"
  chsh -s `which zsh`
fi


# install powerlevel10k
printf '\n\n'
read -p "install powerlevel10k? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n\n####################################\n'
  printf 'installing powerlevel10k...'
  printf '\n####################################\n\n'

  echo "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi


# install rust
printf '\n\n'
read -p "install rust? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n\n####################################\n'
  printf 'installing rust...'
  printf '\n####################################\n\n'
  echo "curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh"
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
fi


# install rust cargo packages
printf '\n\n'
read -p "install rust cargo packages? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n\n####################################\n'
  printf 'installing rust cargo packages...'
  printf '\n####################################\n\n'
  echo "cargo install ${rust_packages[*]}"
  cargo install ${rust_packages[*]}
fi


# install dotfiles
printf '\n\n'
read -p "install dotfiles? (Y/n): " install
if [ $install != 'n' ]; then
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
fi

# install vim
printf '\n\n'
read -p "install VIM? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n\n####################################\n'
  printf 'installing VIM...'
  printf '\n####################################\n\n'

  git clone https://github.com/vim/vim.git
  cd vim/src
  make
  make install
fi


# configure vim
printf '\n\n'
read -p "configure VIM? (Y/n): " install
if [ $install != 'n' ]; then
  printf '\n\n####################################\n'
  printf 'configuring VIM...'
  printf '\n####################################\n\n'

  echo "rm -rf ~/.vim"
  rm -rf ~/.vim

  echo "cp -r ./.vim ~"
  cp -r ./.vim ~

  echo "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

  echo "vi -E -s -u ~/.vimrc +VundleInstall +qall"
  vi -E -s -u ~/.vimrc +VundleInstall +qall
fi


echo 'All done!'
