#!/bin/bash
if [ -z $1 ]; then
  echo "missing sync direction!"
  exit -1
fi

read -p "ssh port: " port

if [ $1 == "up" ]; then

  if [ -z $2 ]; then
    rm -rf ~/.vimsync
    mkdir ~/.vimsync
    mkdir ~/.vimsync/vim
    cp -r ~/.vimrc ~/.vim ~/.vimsync/vim
    rm -rf ~/.vimsync/vim/.vim/bundle ~/.vimsync/.vim/.[!.]*
    scp -r -P $port -q ~/.vimsync/vim luftaquila@luftaquila.io:~/file
    rm -rf ~/.vimsync
    echo "setup upsync done!"

  elif [ $2 == "vimrc" ]; then
    scp -r -P $port -q ~/.vimrc luftaquila@luftaquila.io:~/file/vim
    echo "vimrc upsync done!"

  elif [ $2 == "script" ]; then
    scp -r -P $port -q "$PWD/$0" luftaquila@luftaquila.io:~/file
    echo "script upsync done!"

  else
    echo "unknown target $2!"
    exit -1
  fi

elif [ $1 == "down" ]; then

  if [ -z $2 ]; then
    rm -rf ~/.vimsync
    mkdir ~/.vimsync
    scp -r -P $port -q luftaquila@luftaquila.io:~/file/vim ~/.vimsync
    rm -rf ~/.vim ~/.vimrc
    cp -rf ~/.vimsync/vim/.vim ~/.vim
    cp -f ~/.vimsync/vim/.vimrc ~/.vimrc
    rm -rf ~/.vimsync
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    echo "set nocompatible" >> ~/.vimrc
    echo "filetype plugin indent on" >> ~/.vimrc
    vi +VundleInstall +qall
    echo "setup downsync done!"

  elif [ $2 == "vimrc" ]; then
    scp -r -P $port -q luftaquila@luftaquila.io:~/file/vim/.vimrc ~/.vimrc
    echo "vimrc downsync done!"

  elif [ $2 == "script" ]; then
    scp -r -P $port -q luftaquila@luftaquila.io:~/file/vimsync.sh "$PWD/$0"
    echo "script downsync done!"

  else
    echo "unknown target $2!"
    exit -1
  fi

else
  echo "unknown sync direction $1!"
  exit -1

fi
