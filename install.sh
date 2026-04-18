#!/usr/bin/env bash

###############################################################################
#  configure options
###############################################################################
if [[ $1 == "all" ]]; then
  auto_install=true
else
  auto_install=false
fi

stages=( "Oh My Zsh" "Packages & Languages" )
stages_confirm=( false false )
stages_function=(
  fn_install_ohmyzsh
  fn_install_packages
)

languages=( "python" "node" "rust" )
languages_confirm=( false false false )

packages_brew=(
  "atuin" "bat" "btop" "cmake" "code-minimap"
  "duf" "dust" "eza" "fd" "fzf" "git-delta" "mise"
  "nvim" "rainbarf" "ripgrep" "tig" "tmux"
  "zoxide"
)


################################################################################
#  util functions
################################################################################
function fn_set_distro_config() {
  distro="$1"

  case "$distro" in
    debian)
      pkg_install_cmd='sudo apt-get -y install'
      pkg_update_cmd='sudo apt-get -y update && sudo apt-get -y upgrade'
      packages_system=( "build-essential" "libncurses-dev" "net-tools" "curl" "file" "git" "procps" )
      ;;
    fedora)
      pkg_install_cmd='sudo dnf -y install'
      pkg_update_cmd='sudo dnf -y upgrade'
      packages_system=( "gcc" "gcc-c++" "make" "ncurses-devel" "net-tools" "curl" "file" "git" "procps-ng" "tar" "libatomic" )
      ;;
    arch)
      pkg_install_cmd='sudo pacman -S --noconfirm --needed'
      pkg_update_cmd='sudo pacman -Syu --noconfirm'
      packages_system=( "base-devel" "ncurses" "net-tools" "curl" "file" "git" "procps-ng" )
      ;;
    suse)
      pkg_install_cmd='sudo zypper -n install'
      pkg_update_cmd='sudo zypper -n update'
      packages_system=( "gcc" "gcc-c++" "make" "ncurses-devel" "net-tools" "curl" "file" "git" "procps" )
      ;;
    alpine)
      pkg_install_cmd='sudo apk add'
      pkg_update_cmd='sudo apk update && sudo apk upgrade'
      packages_system=( "build-base" "ncurses-dev" "net-tools" "curl" "file" "git" "procps" "bash" "sudo" )
      ;;
  esac
}

function fn_detect_platform() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    platform='macos'
    distro='macos'
    pkg_install_cmd='brew install'
    pkg_update_cmd='brew update && brew upgrade'
    packages_system=()
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    platform='linux'

    if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      distro_id="$ID"
    else
      distro_id='unknown'
    fi

    case "$distro_id" in
      ubuntu|debian|linuxmint|pop)       fn_set_distro_config debian ;;
      fedora|rhel|centos|rocky|alma)     fn_set_distro_config fedora ;;
      arch|manjaro|endeavouros)          fn_set_distro_config arch ;;
      opensuse*|sles)                    fn_set_distro_config suse ;;
      alpine)                            fn_set_distro_config alpine ;;
      *)
        echo "[WRN] unknown Linux distribution: $distro_id"
        echo "[WRN] attempting to detect package manager..."

        if command -v apt-get &>/dev/null; then   fn_set_distro_config debian
        elif command -v dnf &>/dev/null; then     fn_set_distro_config fedora
        elif command -v pacman &>/dev/null; then  fn_set_distro_config arch
        elif command -v zypper &>/dev/null; then  fn_set_distro_config suse
        elif command -v apk &>/dev/null; then     fn_set_distro_config alpine
        else
          echo "[ERR] no supported package manager found! terminating..."
          exit 1
        fi
        ;;
    esac
  else
    echo "[ERR] unknown OS detected! terminating..."
    exit 1
  fi

  echo "[INF] target OS: $platform ($distro)"
}

function fn_cmd() {
  echo "[CMD] $1"
  eval $1

  if [[ "$?" -ne 0 ]]; then
    echo "[ERR] command failed."

    if [[ $2 == "retry" ]]; then
      echo "[INF] retrying..."
      fn_cmd "$1" $2
    elif [[ $2 == "ignore" ]]; then
      echo "[INF] ignoring..."
    elif [[ $2 == "onfail" ]]; then
      echo "$3"
      exit 1
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

  fn_cmd "ln -s $(pwd)/$target $HOME/$target"
}

function fn_install_prerequisites() {
  if [[ $platform == "linux" ]] && [[ ${#packages_system[@]} -gt 0 ]]; then
    echo "[INF] installing system prerequisites..."
    fn_cmd "$pkg_update_cmd"
    fn_cmd "$pkg_install_cmd ${packages_system[*]}"
  fi
}

function fn_check_homebrew() {
  if ! [[ -x "$(command -v brew)" ]]; then
    echo "[INF] installing Homebrew..."
    fn_cmd 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

    if [[ $platform == "linux" ]]; then
      if [[ -d /home/linuxbrew/.linuxbrew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      elif [[ -d "$HOME/.linuxbrew" ]]; then
        eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
      fi
    fi
  fi
}


################################################################################
#  install functions
################################################################################
function fn_install_ohmyzsh() {
  echo "[INF] installing Oh My Zsh..."

  if ! [[ -x "$(command -v zsh)" ]]; then
    echo "[WRN] no zsh detected! installing it first..."
    fn_cmd "$pkg_install_cmd zsh"
  fi

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    fn_cmd "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"
  else
    echo "[INF] Oh My Zsh is already installled. skipping..."
  fi

  echo "[INF] installing zsh plugins..."

  ZSH_CUSTOM=$(zsh -ic 'echo $ZSH_CUSTOM')

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    fn_cmd "zsh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting'"
  fi

  if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
    fn_cmd "zsh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions'"
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
    local zsh_path
    zsh_path="$(which zsh)"

    if [[ $platform == "macos" ]]; then
      fn_cmd "chsh -s $zsh_path"
    else
      if ! command -v chsh &>/dev/null; then
        echo "[INF] chsh not found. installing..."
        case "$distro" in
          fedora)  fn_cmd "sudo dnf -y install util-linux-user" ;;
          suse)    fn_cmd "sudo zypper -n install util-linux" ;;
          *)       fn_cmd "$pkg_install_cmd util-linux" ;;
        esac
      fi
      fn_cmd "sudo chsh -s $zsh_path $(whoami)"
    fi
  fi
}

function fn_install_packages() {
  echo "[INF] installing packages..."

  fn_cmd "brew install ${packages_brew[*]}"

  fn_install_dotfile ".tigrc"
  fn_install_dotfile ".tmux.conf"

  echo "[INF] installing languages..."

  for i in $(seq 0 $(( ${#languages[@]} - 1 ))); do
    if [[ ${languages_confirm[$i]} == true ]]; then
      echo "[INF] installing ${languages[$i]}..."
      fn_cmd "mise use -g ${languages[$i]}"
    fi
  done

  echo "[INF] configuring tmux..."

  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    fn_cmd "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
  fi

  fn_cmd "tmux start-server"
  fn_cmd "tmux new-session -d"
  fn_cmd "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
  fn_cmd "tmux kill-server"

  echo "[INF] configuring NeoVim..."

  if ! [[ -x "$(mise which python)" ]]; then
    echo "[INF] installing python for pynvim..."
    fn_cmd "mise use -g python"
  fi

  fn_cmd "$(mise which python) -m pip install pynvim"

  if [[ ! -d "$HOME/.config/nvim" ]]; then
    fn_cmd "mkdir -p $HOME/.config"
    fn_cmd "ln -s $HOME/dotfiles/nvim $HOME/.config/nvim"
  fi

  fn_cmd "nvim --headless '+Lazy! sync' +qall" ignore

  echo "[INF] configuring Vim..."

  if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    fn_cmd "git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim"
  fi

  fn_install_dotfile ".vimrc"
  fn_cmd "vim -Es -u $HOME/.vimrc +VundleInstall +qall" ignore

  echo "[INF] installing Claude Code..."
  fn_cmd "curl -fsSL https://claude.ai/install.sh | bash"
  fn_cmd "claude plugin marketplace add https://github.com/wakatime/claude-code-wakatime.git"
  fn_cmd "claude plugin i claude-code-wakatime@wakatime"

  echo "[INF] configuring Claude Code..."
  fn_cmd "mkdir -p $HOME/.claude/hud"

  for f in settings.json hud/status.mjs; do
    if [[ -f "$HOME/.claude/$f" ]] && [[ ! -L "$HOME/.claude/$f" ]]; then
      fn_cmd "cp $HOME/.claude/$f ./backups/.claude-$(basename $f)"
      fn_cmd "rm -f $HOME/.claude/$f"
    fi
    fn_cmd "ln -sf $(pwd)/tools/claude/$f $HOME/.claude/$f"
  done
}


################################################################################
#  identify dotfiles repository
################################################################################
function fn_set_directory() {
  echo "[INF] looking for dotfiles..."

  if [[ -d "$HOME/dotfiles" ]]; then
    fn_cmd "cd $HOME/dotfiles"

    if ! $(git remote -v | grep -q 'luftaquila/dotfiles'); then
      echo "[ERR] existing dotfiles directory is not from luftaquila/dotfiles. terminating..."
      exit 1
    else
      echo "[INF] existing dotfiles directory found"
      fn_cmd "git fetch origin"

      if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
        echo "[INF] updating dotfiles..."
        fn_cmd "git pull origin main" onfail "[ERR] cannot update dotfiles due to conflict. terminating..."
        echo "[INF] installation script updated. restarting..."
        exec ./install.sh $1
        exit 0
      fi
    fi
  else
    echo "[INF] cloning dotfiles..."
    fn_cmd "git clone https://github.com/luftaquila/dotfiles.git $HOME/dotfiles"
    fn_cmd "cd $HOME/dotfiles"
    exec ./install.sh $1
    exit 0
  fi

  fn_install_dotfile ".gitconfig"
}

################################################################################
#  configure stages
################################################################################
function fn_configure_stages() {
  if ! [[ "$auto_install" = true ]]; then
    echo "[INF] configuring stages..."

    for i in $(seq 0 $(( ${#stages[@]} - 1 ))); do
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

    if [[ ${stages_confirm[1]} == true ]]; then
      for i in $(seq 0 $(( ${#languages[@]} - 1 ))); do
        while true; do
          input=''
          read -p "    install ${languages[$i]}? (Y/n): " input

          if [ -z $input ] || [ $input == 'y' ] || [ $input == 'Y' ]; then
            languages_confirm[$i]=true
            break
          elif [ $input == 'n' ] || [ $input == 'N' ]; then
            languages_confirm[$i]=false
            break
          else
            echo "      invalid input"
          fi
        done
      done
    fi

    echo
    echo "[INF] confirm the configurations:"

    for i in $(seq 0 $(( ${#stages[@]} - 1 ))); do
      echo -e "  ${stages[$i]}\033[30G${stages_confirm[$i]}"
    done

    for i in $(seq 0 $(( ${#languages[@]} - 1 ))); do
      echo -e "    ${languages[$i]}\033[30G${languages_confirm[$i]}"
    done

    echo
    read -p "  Press ENTER to continue..."
  else
    for i in $(seq 0 $(( ${#stages[@]} - 1 ))); do
      stages_confirm[$i]=true
    done

    for i in $(seq 0 $(( ${#languages[@]} - 1 ))); do
      languages_confirm[$i]=true
    done
  fi
}

function fn_execute_stages() {
  fn_cmd "brew update && brew upgrade"

  for i in $(seq 0 $(( ${#stages[@]} - 1 ))); do
    if [[ ${stages_confirm[$i]} == true ]]; then
      eval ${stages_function[$i]}
    fi
  done
}

function fn_install_authorized_keys() {
  echo "[INF] installing authorized_keys from github.com/luftaquila.keys..."

  fn_cmd "mkdir -p $HOME/.ssh"
  fn_cmd "chmod 700 $HOME/.ssh"

  if [[ -f $HOME/.ssh/authorized_keys ]]; then
    fn_cmd "cp $HOME/.ssh/authorized_keys ./backups/authorized_keys"
  fi

  fn_cmd "curl -fsSL https://github.com/luftaquila.keys -o $HOME/.ssh/authorized_keys"
  fn_cmd "chmod 600 $HOME/.ssh/authorized_keys"
}

function fn_generate_ssh_key() {
  ssh_pubkey=$HOME/.ssh/id_ed25519

  if ! [[ -f $ssh_pubkey ]]; then
    echo "[INF] no ssh key found! generating new one..."
    fn_cmd "ssh-keygen -t ed25519 -f $ssh_pubkey -N '' <<< y"
  fi

  echo "[INF] ssh key: $(cat $ssh_pubkey.pub)"
  echo "[INF] assign this key to GitHub at https://github.com/settings/keys"

  while true; do
    input=''
    read -p "Replace dotfile remote url from https to ssh? (Y/n): " input

    if [ -z $input ] || [ $input == 'y' ] || [ $input == 'Y' ]; then
      fn_cmd "git remote set-url origin git@github.com:luftaquila/dotfiles.git"
      break
    elif [ $input == 'n' ] || [ $input == 'N' ]; then
      break
    else
      echo "  invalid input"
    fi
  done
}


################################################################################
#  launch
################################################################################
fn_detect_platform
fn_install_prerequisites
fn_check_homebrew
fn_set_directory $1
fn_configure_stages
fn_execute_stages
echo "[INF] ALL DONE!"
fn_install_authorized_keys
fn_generate_ssh_key
echo "[INF] starting in new zsh..."
exec zsh
