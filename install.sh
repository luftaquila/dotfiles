#!/bin/bash

###############################################################################
#  configure options
###############################################################################
if [[ $1 == "all" ]]; then
  auto_install=true
else
  auto_install=false
fi

package_cmd_update=false

###############################################################################
#  stage definitions
###############################################################################
stages=( "system packages" "tmux" "Languages" "NeoVim" "Oh My Zsh" )
stages_confirm=( true true true true true )

stages_language=( "Python" "Node.js" "Rust" )
stages_language_confirm=( true true true )

stages_function=(
  fn_install_system_packages
  fn_install_tmux
  fn_install_lang
  fn_install_neovim
  fn_install_ohmyzsh
)

###############################################################################
#  package definitions
###############################################################################
packages_apt=( "build-essential" "libncurses-dev" "net-tools" )
packages_brew=( "bat" "btop" "cmake" "code-minimap" "dust" "eza" "fd" "fzf" "git-delta" "ripgrep" "zoxide" )

################################################################################
#  detect OS
################################################################################
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  platform='linux'
  package_cmd='sudo apt-get -y'
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
    if [[ $2 == "retry" ]]; then
      echo "[INF] retrying..."
      fn_cmd "$1" $2
    elif [[ $2 == "ignore" ]]; then
      :
    else
      echo "[INF] terminating..."
      exit 1
    fi
  fi
}

function fn_install_dotfile() {
  target=$1

  echo "[INF] installing $target..."

  fn_cmd "mkdir -p backups"

  if [[ -f $HOME/$target ]]; then
    fn_cmd "cp $HOME/$target ./backups/$target"
    fn_cmd "rm -f $HOME/$target"
  fi

  fn_cmd "ln -s `pwd`/$target $HOME/$target"
}

function fn_update() {
  if [[ "$package_cmd_update" = false ]]; then
    fn_cmd "$package_cmd update && $package_cmd upgrade"
    package_cmd_update=true
  fi
}

function fn_install_system_packages() {
  echo "[INF] installing system packages..."

  fn_update

  if [[ $platform == "linux" ]]; then
    fn_cmd "$package_cmd install ${packages_apt[*]}"

    if ! [[ -x "$(command -v brew)" ]]; then
      echo "[INF] installing Homebrew..."
      fn_cmd '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      fn_cmd 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    fi
  fi

  echo "[INF] installing Homebrew packages..."
  fn_cmd "brew install ${packages_brew[*]}"
}

function fn_install_tmux() {
  echo "[INF] installing tmux..."

  fn_update
  fn_cmd "$package_cmd install tmux"

  fn_install_dotfile ".tmux.conf"

  # rainbarf
  if [[ $platform == "linux" ]]; then
    if [[ ! -d "$HOME/.tmux/plugins/rainbarf" ]]; then
      fn_cmd "git clone https://github.com/creaktive/rainbarf $HOME/.tmux/plugins/rainbarf"
    fi

    if [[ ! -f "$HOME/.local/bin/rainbarf" ]]; then
      fn_cmd "mkdir -p $HOME/.local/bin"
      fn_cmd "ln -s $HOME/.tmux/plugins/rainbarf/rainbarf $HOME/.local/bin/rainbarf"
    fi
  elif [[ $platform == "macos" ]]; then
    fn_cmd "$package_cmd install rainbarf"
  fi

  # tpm
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    fn_cmd "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
  fi

  fn_cmd "tmux start-server"
  fn_cmd "tmux new-session -d"
  fn_cmd "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
  fn_cmd "tmux kill-server"
}

function fn_install_lang() {
  echo "[INF] installing mise..."

  if ! [[ -x "$(command -v mise)" ]]; then
    if ! [ -f "$HOME/.local/bin/mise" ]; then
      fn_cmd "curl https://mise.run | sh"
    else
      echo "[INF] mise is already installed, but not activated yet"
    fi

    echo "[INF] activating mise..."

    if [[ $SHELL == *zsh* ]]; then
      fn_cmd 'eval "$(~/.local/bin/mise activate zsh)"'
    elif [[ $SHELL == *bash* ]]; then
      fn_cmd 'eval "$(~/.local/bin/mise activate bash)"'
    else
      echo "[ERR] $SHELL is not supported"
    fi
  else
    echo "[INF] mise is already installed. skipping..."
  fi

  for i in `seq 0 $(( ${#stages_language[@]} - 1 ))`; do
    if [[ ${stages_language_confirm[$i]} == true ]]; then
      if [[ ${stages_language[$i]} == "Python" ]]; then
        echo "[INF] installing Python..."
        fn_cmd 'mise use -g python'
      fi

      if [[ ${stages_language[$i]} == "Node.js" ]]; then
        echo "[INF] installing Node.js..."
        fn_cmd 'mise use -g node'
      fi

      if [[ ${stages_language[$i]} == "Rust" ]]; then
        echo "[INF] installing Rust..."

        if ! [[ -x "$(command -v rustc)" ]]; then
          fn_cmd "curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y"
          fn_cmd "source $HOME/.cargo/env"
        else
          echo "[INF] Rust is already installed. skipping..."
        fi

        echo "[INF] installing Rust Cargo crates..."

        if [[ ${#packages_rust_common[@]} -ne 0 ]]; then
          fn_cmd "cargo install ${packages_rust_common[*]}"
        fi

        if [[ $platform == "linux" ]]; then
          if [[ ${#packages_rust_linux[@]} -ne 0 ]]; then
            fn_cmd "cargo install ${packages_rust_linux[*]}"
          fi
        elif [[ $platform == "macos" ]]; then
          if [[ ${#packages_rust_macos[@]} -ne 0 ]]; then
            fn_cmd "cargo install ${packages_rust_macos[*]}"
          fi
        fi
      fi
    fi
  done
}

function fn_install_neovim() {
  echo "[INF] installing NeoVim..."

  fn_update

  if ! [[ -x "$(command -v nvim)" ]]; then
    if [[ $platform == "linux" ]]; then
      fn_cmd "$package_cmd install fuse3 libfuse2"
      fn_cmd "curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage -o $HOME/.local/bin/nvim"
      fn_cmd "chmod 744 $HOME/.local/bin/nvim"
      fn_cmd 'PATH="$HOME/.local/bin:$PATH"'
    elif [[ $platform == "macos" ]]; then
      fn_cmd "$package_cmd install neovim"
    fi
    fn_cmd "pip install pynvim"
  else
    echo "[INF] NeoVim is already installed. skipping..."
  fi

  echo "[INF] configuring NeoVim..."

  if [[ ! -d "$HOME/.config/nvim" ]]; then
    fn_cmd "mkdir -p $HOME/.config"
    fn_cmd "ln -s $HOME/dotfiles/nvim $HOME/.config/nvim"
  fi

  echo "[INF] installing Vim..."

  fn_cmd "git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim"
  fn_cmd "ln -s $HOME/dotfiles/.vimrc $HOME/.vimrc"
  fn_cmd "vim -Es -u $HOME/.vimrc +VundleInstall +qall" ignore
}

function fn_install_ohmyzsh() {
  echo "[INF] installing Oh My Zsh..."

  fn_update

  if ! [[ -x "$(command -v zsh)" ]]; then
    echo "[WRN] no zsh detected! installing it first..."
    fn_cmd "$package_cmd install zsh"
  fi

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    fn_cmd "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"
  else
    echo "[INF] Oh My Zsh is already installled. skipping..."
  fi

  echo "[INF] installing zsh plugins..."

  ZSH_CUSTOM=`zsh -ic 'echo $ZSH_CUSTOM'`

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    fn_cmd "zsh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting'"
  fi

  if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
    fn_cmd "zsh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions'"
  fi

  if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-hangul" ]]; then
    fn_cmd "zsh -c 'git clone https://github.com/gomjellie/zsh-hangul ${ZSH_CUSTOM}/plugins/zsh-hangul'"
  fi

  echo "[INF] installing powerlevel10k..."

  if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    fn_cmd "zsh -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'"
  fi

  fn_install_dotfile ".zshrc"
  fn_install_dotfile ".p10k.zsh"

  echo "[INF] installing per-machine zsh script..."

  if [[ ! -f "$HOME/.machine.zsh" ]]; then
    fn_cmd "cp ./.machine.zsh.example $HOME/.machine.zsh"
  else
    echo "[INF] existing .machine.zsh found! skipping..."
  fi

  if ! [[ $SHELL == *'zsh'* ]]; then
    echo "[INF] replacing default shell to zsh..."
    fn_cmd "chsh -s `which zsh`" retry
  fi
}


################################################################################
#  check git installation
################################################################################
if ! [[ -x "$(command -v git)" ]]; then
  echo "[ERR] no git detected!"
  echo "[INF] installing git..."
  fn_update
  fn_cmd "$package_cmd install git"
fi


################################################################################
#  identify dotfiles repository
################################################################################
echo "[INF] looking for dotfiles..."

# current directory is not $HOME/dotfiles
if ! `git remote -v | grep -q 'luftaquila/dotfiles'`; then

  # if exist
  if [[ -d "$HOME/dotfiles" ]]; then
    fn_cmd "cd $HOME/dotfiles"

    echo "[INF] restarting in dotfiles directory..."
    exec ./install.sh $1
  fi

  # check ssh client
  if ! [[ -x "$(command -v ssh)" ]]; then
    echo "[ERR] no ssh client detected!"
    echo "[INF] installing openssh..."
    fn_update
    fn_cmd "$package_cmd install $openssh_name"
  fi

  # check ssh key
  ssh_pubkey=$HOME/.ssh/id_ed25519
  if ! [[ -f $ssh_pubkey ]]; then
    echo "[INF] no ssh key found! generating new..."
    fn_cmd "ssh-keygen -t ed25519 -f $ssh_pubkey -N '' <<< y"
  fi
  echo "[INF] ssh key: `cat $ssh_pubkey.pub`"
  echo "[INF] assign the key at https://github.com/settings/keys"
  read -p "  Press ENTER to continue..."

  # cloning dotfiles
  echo "[INF] cloning dotfiles..."
  fn_cmd "git clone git@github.com:luftaquila/dotfiles.git $HOME/dotfiles"
  fn_cmd "cd $HOME/dotfiles"

  echo "[INF] restarting in cloned directory..."
  exec ./install.sh $1
fi

fn_install_dotfile ".gitconfig"


################################################################################
#  configure stages
################################################################################
if ! [[ "$auto_install" = true ]]; then
  echo "[INF] configuring stages..."

  for i in `seq 0 $(( ${#stages[@]} - 1 ))`; do
    while true; do
      input=''
      read -p "  install ${stages[$i]}? (Y/n): " input

      if [ -z $input ] || [ $input == 'y' ] || [ $input == 'Y' ]; then
        stages_confirm[$i]=true

        # configure languages support
        if [[ ${stages[$i]} == "Languages" ]]; then
          for i in `seq 0 $(( ${#stages_language[@]} - 1 ))`; do
            while true; do
              input=''
              read -p "    install ${stages_language[$i]}? (Y/n): " input

              if [ -z $input ] || [ $input == 'y' ] || [ $input == 'Y' ]; then
                stages_language_confirm[$i]=true
                break
              elif [ $input == 'n' ] || [ $input == 'N' ]; then
                stages_language_confirm[$i]=false
                break
              else
                echo "    invalid input"
              fi
            done
          done
        fi
        break

      elif [ $input == 'n' ] || [ $input == 'N' ]; then
        stages_confirm[$i]=false
        break

      else
        echo "    invalid input"
      fi
    done
  done

  echo
  echo "[INF] please confirm the configurations:"

  for i in `seq 0 $(( ${#stages[@]} - 1 ))`; do
    echo -e "  ${stages[$i]}\033[20G${stages_confirm[$i]}"

    if [[ ${stages[$i]} == "Languages" && ${stages_confirm[$i]} == true ]]; then
      for i in `seq 0 $(( ${#stages_language[@]} - 1 ))`; do
        echo -e "    ${stages_language[$i]}\033[22G${stages_language_confirm[$i]}"
      done
    fi
  done

  echo
  read -p "  Press ENTER to continue..."
fi


################################################################################
#  execute stages
################################################################################
for i in `seq 0 $(( ${#stages[@]} - 1 ))`; do
  if [[ ${stages_confirm[$i]} == true ]]; then
    eval ${stages_function[$i]}
  fi
done


################################################################################
#  launch
################################################################################
echo "[INF] ALL DONE!"
echo "[INF] starting in new zsh..."
exec zsh
