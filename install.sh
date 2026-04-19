#!/usr/bin/env bash

set -uo pipefail


###############################################################################
#  configuration
###############################################################################
packages_brew=(
  "atuin" "bat" "btop" "cmake" "code-minimap"
  "duf" "dust" "eza" "fd" "fzf" "git-delta" "mise"
  "nvim" "rainbarf" "ripgrep" "tig" "tmux"
  "zoxide"
)

# selection keys — labels and dependencies defined in fn_configure_items
item_keys=( ohmyzsh brew lang-python lang-node lang-rust tmux nvim vim claude )
declare -A sel=()

# state (populated by argv parsing)
auto_install=false
dry_run=false
quiet=false
only_items=""
log_file=""
DOTFILES_DIR=""


###############################################################################
#  argv parsing
###############################################################################
function usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  -h, --help              Show this help and exit
  -a, --all               Install all items without prompting
  -n, --dry-run           Print commands without executing
  -q, --quiet             Suppress [CMD] output
      --only=ITEMS        Comma-separated items (skips prompts; auto-resolves deps)
      --log               Log to ~/.dotfiles-install-<timestamp>.log
      --log=FILE          Log to FILE

Available items: ${item_keys[*]}
EOF
}

# preserve original args for re-exec after dotfile pull
ORIG_ARGS=("$@")

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)        usage; exit 0 ;;
    -a|--all|all)     auto_install=true; shift ;;
    -n|--dry-run)     dry_run=true; shift ;;
    -q|--quiet)       quiet=true; shift ;;
    --only=*)         only_items="${1#--only=}"; shift ;;
    --only)           only_items="${2:-}"; shift 2 ;;
    --log)            log_file="$HOME/.dotfiles-install-$(date +%Y%m%d-%H%M%S).log"; shift ;;
    --log=*)          log_file="${1#--log=}"; shift ;;
    *)                echo "[ERR] unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# log file: tee stdout+stderr (skip if already set up by parent process re-exec)
if [[ -n $log_file ]] && [[ -z ${DOTFILES_INSTALL_LOG_SETUP:-} ]]; then
  export DOTFILES_INSTALL_LOG_SETUP=1
  exec > >(tee -a "$log_file") 2>&1
  echo "[INF] logging to $log_file"
fi


###############################################################################
#  colors
###############################################################################
if [[ -t 0 ]]; then
  C_R=$'\033[0m'; C_B=$'\033[1m'; C_D=$'\033[2m'
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'; C_CYN=$'\033[36m'
else
  C_R=''; C_B=''; C_D=''
  C_RED=''; C_GRN=''; C_YLW=''; C_CYN=''
fi


###############################################################################
#  util functions
###############################################################################
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
  if [[ $quiet != true ]]; then
    echo "[CMD] $1"
  fi

  if [[ $dry_run == true ]]; then
    return 0
  fi

  eval "$1"

  if [[ "$?" -ne 0 ]]; then
    echo "[ERR] command failed."

    if [[ ${2:-} == "ignore" ]]; then
      echo "[INF] ignoring..."
    elif [[ ${2:-} == "onfail" ]]; then
      echo "${3:-}"
      exit 1
    else
      echo "[INF] terminating..."
      exit 1
    fi
  fi
}

function fn_install_dotfile() {
  local target=$1

  echo "[INF] installing $target..."

  fn_cmd "mkdir -p $DOTFILES_DIR/backups"

  if [[ -L $HOME/$target ]]; then
    # existing symlink (including broken ones) — remove without backup
    fn_cmd "rm -f $HOME/$target"
  elif [[ -f $HOME/$target ]]; then
    fn_cmd "cp $HOME/$target $DOTFILES_DIR/backups/$target"
    fn_cmd "rm -f $HOME/$target"
  fi

  fn_cmd "ln -s $DOTFILES_DIR/$target $HOME/$target"
}

function fn_install_prerequisites() {
  if [[ $platform != "linux" ]] || [[ ${#packages_system[@]} -eq 0 ]]; then
    return
  fi

  # skip system update if core toolchain is already present (re-run case)
  if command -v git &>/dev/null && command -v curl &>/dev/null \
     && command -v make &>/dev/null && command -v gcc &>/dev/null; then
    echo "[INF] core prerequisites already present. skipping system update..."
    return
  fi

  echo "[INF] installing system prerequisites..."
  fn_cmd "$pkg_update_cmd"
  fn_cmd "$pkg_install_cmd ${packages_system[*]}"
}

function fn_check_homebrew() {
  # already on PATH — nothing to do
  if command -v brew &>/dev/null; then
    return
  fi

  # well-known locations (Apple Silicon, Intel mac, Linuxbrew system-wide, Linuxbrew user)
  local candidates=(
    /opt/homebrew/bin/brew
    /usr/local/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew
    "$HOME/.linuxbrew/bin/brew"
  )

  local brew_bin=""
  for p in "${candidates[@]}"; do
    if [[ -x $p ]]; then
      brew_bin=$p
      break
    fi
  done

  # installed but not on PATH — just source shellenv
  if [[ -n $brew_bin ]]; then
    echo "[INF] Homebrew found at $brew_bin but not on PATH. sourcing shellenv..."
    eval "$($brew_bin shellenv)"
    return
  fi

  echo "[INF] installing Homebrew..."
  fn_cmd 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

  # locate the freshly-installed brew and source shellenv
  for p in "${candidates[@]}"; do
    if [[ -x $p ]]; then
      eval "$($p shellenv)"
      break
    fi
  done
}


###############################################################################
#  prompts & UI
###############################################################################
ASK_RESULT=""

function fn_ask_yn() {
  local prompt=$1
  local default=${2:-y}
  local indent=${3:-""}
  local dhint
  if [[ $default == "n" ]]; then
    dhint="(y/N)"
  else
    dhint="(Y/n)"
  fi

  while true; do
    local input=''
    printf "%s%s?%s %s %s%s%s: " "$indent" "$C_CYN" "$C_R" "$prompt" "$C_D" "$dhint" "$C_R"
    read -r input
    input=${input:-$default}
    case $input in
      y|Y) ASK_RESULT=true;  return ;;
      n|N) ASK_RESULT=false; return ;;
      *)   printf "%s  %sinvalid input%s\n" "$indent" "$C_YLW" "$C_R" ;;
    esac
  done
}

function fn_print_item() {
  local key=$1 label=$2 indent=${3:-""}
  local mark
  if [[ ${sel[$key]} == true ]]; then
    mark="${C_GRN}✓${C_R}"
  else
    mark="${C_D}✗${C_R}"
  fi
  printf "  %s%s %s\n" "$indent" "$mark" "$label"
}

function fn_print_header() {
  local title=$1
  local line
  line=$(printf '%.0s─' $(seq 1 ${#title}))
  echo
  printf "%s%s%s\n" "$C_B" "$title" "$C_R"
  printf "%s%s%s\n" "$C_D" "$line" "$C_R"
}

function fn_print_summary() {
  fn_print_header "Summary"
  fn_print_item ohmyzsh       "Oh My Zsh"
  fn_print_item brew          "Homebrew packages"
  if [[ ${sel[brew]} == true ]]; then
    fn_print_item lang-python "python"  "  "
    fn_print_item lang-node   "node"    "  "
    fn_print_item lang-rust   "rust"    "  "
    fn_print_item tmux        "tmux"    "  "
    fn_print_item nvim        "NeoVim"  "  "
  fi
  fn_print_item vim           "Vim"
  fn_print_item claude        "Claude Code"
}


###############################################################################
#  install functions
###############################################################################
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
    fn_cmd "cp $DOTFILES_DIR/.machine.zsh.example $HOME/.machine.zsh"
  else
    echo "[INF] existing .machine.zsh found! skipping..."
  fi

  if [[ $platform == "linux" ]] && ! [[ $SHELL == *'zsh'* ]]; then
    echo "[INF] replacing default shell to zsh..."
    local zsh_path
    zsh_path="$(command -v zsh)"

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
}

function fn_install_brew_packages() {
  echo "[INF] installing Homebrew packages..."
  fn_check_homebrew
  fn_cmd "brew update && brew upgrade" ignore
  fn_cmd "brew install ${packages_brew[*]}"
  fn_install_dotfile ".tigrc"
}

function fn_install_languages() {
  echo "[INF] installing languages via mise..."
  for lang in "$@"; do
    echo "[INF] installing $lang..."
    fn_cmd "mise use -g $lang"
  done
}

function fn_install_tmux() {
  echo "[INF] configuring tmux..."
  fn_install_dotfile ".tmux.conf"

  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    fn_cmd "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
  fi

  # isolated tmux tmpdir so kill-server doesn't terminate user's sessions
  local prev_tmpdir=${TMUX_TMPDIR:-}
  export TMUX_TMPDIR="/tmp/dotfiles-install-tmux-$$"
  fn_cmd "mkdir -p $TMUX_TMPDIR"

  fn_cmd "tmux start-server"
  fn_cmd "tmux new-session -d"
  fn_cmd "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" ignore
  fn_cmd "tmux kill-server" ignore
  fn_cmd "rm -rf $TMUX_TMPDIR"

  if [[ -n $prev_tmpdir ]]; then
    export TMUX_TMPDIR="$prev_tmpdir"
  else
    unset TMUX_TMPDIR
  fi
}

function fn_install_nvim() {
  echo "[INF] configuring NeoVim..."

  if ! [[ -x "$(mise which python)" ]]; then
    echo "[INF] installing python for pynvim..."
    fn_cmd "mise use -g python"
  fi

  fn_cmd "$(mise which python) -m pip install pynvim" ignore

  fn_cmd "mkdir -p $HOME/.config"

  if [[ -L "$HOME/.config/nvim" ]]; then
    fn_cmd "rm -f $HOME/.config/nvim"
  elif [[ -d "$HOME/.config/nvim" ]]; then
    echo "[INF] backing up existing nvim config directory..."
    fn_cmd "mkdir -p $DOTFILES_DIR/backups"
    fn_cmd "mv $HOME/.config/nvim $DOTFILES_DIR/backups/nvim-$(date +%Y%m%d%H%M%S)"
  fi

  fn_cmd "ln -s $DOTFILES_DIR/nvim $HOME/.config/nvim"
  fn_cmd "nvim --headless '+Lazy! sync' +qall" ignore
}

function fn_install_vim() {
  echo "[INF] configuring Vim..."

  if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    fn_cmd "git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim"
  fi

  fn_install_dotfile ".vimrc"
  fn_cmd "vim -Es -u $HOME/.vimrc +VundleInstall +qall" ignore
}

function fn_install_claude() {
  if ! command -v claude &>/dev/null; then
    echo "[INF] installing Claude Code..."
    fn_cmd "curl -fsSL https://claude.ai/install.sh | bash"
    # Claude's installer writes to ~/.local/bin but doesn't update current shell's PATH —
    # without this, the plugin commands below would silently fail on a fresh install
    if ! command -v claude &>/dev/null && [[ -x "$HOME/.local/bin/claude" ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi
  else
    echo "[INF] Claude Code is already installed. skipping install..."
  fi

  # plugin commands may fail if marketplace/plugin already present — that's OK
  fn_cmd "claude plugin marketplace add https://github.com/wakatime/claude-code-wakatime.git" ignore
  fn_cmd "claude plugin i claude-code-wakatime@wakatime" ignore

  echo "[INF] configuring Claude Code..."
  fn_cmd "mkdir -p $HOME/.claude/hud"

  for f in settings.json hud/status.mjs; do
    if [[ -L "$HOME/.claude/$f" ]]; then
      fn_cmd "rm -f $HOME/.claude/$f"
    elif [[ -f "$HOME/.claude/$f" ]]; then
      fn_cmd "mkdir -p $DOTFILES_DIR/backups"
      fn_cmd "cp $HOME/.claude/$f $DOTFILES_DIR/backups/.claude-$(basename $f)"
      fn_cmd "rm -f $HOME/.claude/$f"
    fi
    fn_cmd "ln -s $DOTFILES_DIR/tools/claude/$f $HOME/.claude/$f"
  done
}


###############################################################################
#  identify dotfiles repository
###############################################################################
function fn_set_directory() {
  echo "[INF] looking for dotfiles..."

  if [[ -d "$HOME/dotfiles" ]]; then
    fn_cmd "cd $HOME/dotfiles"

    if ! git remote -v | grep -q 'luftaquila/dotfiles'; then
      echo "[ERR] existing dotfiles directory is not from luftaquila/dotfiles. terminating..."
      exit 1
    fi

    echo "[INF] existing dotfiles directory found"
    fn_cmd "git fetch origin"

    if [[ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]]; then
      echo "[INF] updating dotfiles..."
      fn_cmd "git pull origin main" onfail "[ERR] cannot update dotfiles due to conflict. terminating..."
      echo "[INF] installation script updated. restarting..."
      if [[ ${#ORIG_ARGS[@]} -gt 0 ]]; then
        exec ./install.sh "${ORIG_ARGS[@]}"
      else
        exec ./install.sh
      fi
    fi
  else
    echo "[INF] cloning dotfiles..."
    fn_cmd "git clone https://github.com/luftaquila/dotfiles.git $HOME/dotfiles"
    fn_cmd "cd $HOME/dotfiles"
    if [[ ${#ORIG_ARGS[@]} -gt 0 ]]; then
      exec ./install.sh "${ORIG_ARGS[@]}"
    else
      exec ./install.sh
    fi
  fi

  DOTFILES_DIR=$(pwd)
  fn_install_dotfile ".gitconfig"
}


###############################################################################
#  configure & execute items
#
#  dependency graph:
#    ohmyzsh      — independent
#    brew         — provides mise, tmux, nvim, tig binaries
#    lang-python  ⇐ brew (via mise)
#    lang-node    ⇐ brew (via mise)
#    lang-rust    ⇐ brew (via mise)
#    tmux         ⇐ brew (tmux binary for tpm install)
#    nvim         ⇐ brew (nvim binary) + lang-python (pynvim)
#    vim          — independent (uses system vim)
#    claude       — independent
###############################################################################
function fn_apply_only_filter() {
  local requested=()
  IFS=',' read -ra requested <<< "$only_items"

  local item k found
  for item in "${requested[@]}"; do
    found=false
    for k in "${item_keys[@]}"; do
      if [[ $k == "$item" ]]; then
        sel[$k]=true
        found=true
        break
      fi
    done
    if [[ $found != true ]]; then
      echo "[ERR] unknown item: $item (available: ${item_keys[*]})" >&2
      exit 1
    fi
  done

  # auto-resolve dependencies
  if [[ ${sel[lang-python]} == true || ${sel[lang-node]} == true || ${sel[lang-rust]} == true \
     || ${sel[tmux]} == true || ${sel[nvim]} == true ]]; then
    sel[brew]=true
  fi
  if [[ ${sel[nvim]} == true && ${sel[lang-python]} != true ]]; then
    sel[lang-python]=true
  fi
}

function fn_configure_items() {
  for k in "${item_keys[@]}"; do sel[$k]=false; done

  if [[ -n $only_items ]]; then
    fn_apply_only_filter
    fn_print_header "Selected (--only=$only_items)"
    fn_print_summary
    return
  fi

  if [[ "$auto_install" = true ]]; then
    for k in "${item_keys[@]}"; do sel[$k]=true; done
    return
  fi

  while true; do
    fn_print_header "Installation Options"
    echo

    fn_ask_yn "Oh My Zsh ${C_D}(zsh, plugins, p10k)${C_R}" "y"
    sel[ohmyzsh]=$ASK_RESULT

    fn_ask_yn "Homebrew packages ${C_D}(CLI tools: mise, nvim, tmux, tig, ...)${C_R}" "y"
    sel[brew]=$ASK_RESULT

    if [[ ${sel[brew]} == true ]]; then
      printf "  %slanguages (via mise):%s\n" "$C_D" "$C_R"
      fn_ask_yn "python"  "y" "    "; sel[lang-python]=$ASK_RESULT
      fn_ask_yn "node"    "y" "    "; sel[lang-node]=$ASK_RESULT
      fn_ask_yn "rust"    "y" "    "; sel[lang-rust]=$ASK_RESULT

      printf "  %sconfigs:%s\n" "$C_D" "$C_R"
      fn_ask_yn "tmux ${C_D}+ tpm plugins${C_R}"     "y" "    "; sel[tmux]=$ASK_RESULT
      fn_ask_yn "NeoVim ${C_D}+ Lazy plugins${C_R}"  "y" "    "; sel[nvim]=$ASK_RESULT

      # nvim -> python (pynvim)
      if [[ ${sel[nvim]} == true ]] && [[ ${sel[lang-python]} != true ]]; then
        printf "      %s!%s NeoVim requires python (pynvim) — auto-enabling python\n" "$C_YLW" "$C_R"
        sel[lang-python]=true
      fi
    fi

    fn_ask_yn "Vim ${C_D}+ Vundle${C_R}"  "y"; sel[vim]=$ASK_RESULT
    fn_ask_yn "Claude Code"               "y"; sel[claude]=$ASK_RESULT

    fn_print_summary
    echo

    local action=''
    while true; do
      printf "%s?%s [%sc%s]ontinue / [%se%s]dit / [%sa%s]bort: " \
        "$C_CYN" "$C_R" "$C_GRN" "$C_R" "$C_YLW" "$C_R" "$C_RED" "$C_R"
      read -r action
      action=${action:-c}
      case $action in
        c|C) return ;;
        e|E) break ;;
        a|A) echo "[INF] aborting."; exit 0 ;;
        *)   printf "  %sinvalid input%s\n" "$C_YLW" "$C_R" ;;
      esac
    done
  done
}

function fn_execute_items() {
  [[ ${sel[ohmyzsh]} == true ]] && fn_install_ohmyzsh

  if [[ ${sel[brew]} == true ]]; then
    fn_install_brew_packages

    local langs=()
    [[ ${sel[lang-python]} == true ]] && langs+=(python)
    [[ ${sel[lang-node]}   == true ]] && langs+=(node)
    [[ ${sel[lang-rust]}   == true ]] && langs+=(rust)
    [[ ${#langs[@]} -gt 0 ]] && fn_install_languages "${langs[@]}"

    [[ ${sel[tmux]} == true ]] && fn_install_tmux
    [[ ${sel[nvim]} == true ]] && fn_install_nvim
  fi

  [[ ${sel[vim]}    == true ]] && fn_install_vim
  [[ ${sel[claude]} == true ]] && fn_install_claude

  return 0
}


###############################################################################
#  post-install
###############################################################################
function fn_install_authorized_keys() {
  echo "[INF] installing authorized_keys from github.com/luftaquila.keys..."

  fn_cmd "mkdir -p $HOME/.ssh"
  fn_cmd "chmod 700 $HOME/.ssh"

  if [[ -f $HOME/.ssh/authorized_keys ]]; then
    fn_cmd "mkdir -p $DOTFILES_DIR/backups"
    fn_cmd "cp $HOME/.ssh/authorized_keys $DOTFILES_DIR/backups/authorized_keys"
  fi

  fn_cmd "curl -fsSL https://github.com/luftaquila.keys -o $HOME/.ssh/authorized_keys" ignore

  if [[ -f $HOME/.ssh/authorized_keys ]]; then
    fn_cmd "chmod 600 $HOME/.ssh/authorized_keys"
  fi
}

function fn_generate_ssh_key() {
  local ssh_pubkey=$HOME/.ssh/id_ed25519

  if [[ ! -f $ssh_pubkey ]]; then
    echo "[INF] no ssh key found! generating new one..."
    fn_cmd "ssh-keygen -t ed25519 -f $ssh_pubkey -N '' <<< y"
  fi

  echo "[INF] ssh key: $(cat $ssh_pubkey.pub)"
  echo "[INF] assign this key to GitHub at https://github.com/settings/keys"

  while true; do
    local input=''
    read -rp "Replace dotfile remote url from https to ssh? (Y/n): " input
    input=${input:-y}

    if [[ $input == 'y' || $input == 'Y' ]]; then
      fn_cmd "git remote set-url origin git@github.com:luftaquila/dotfiles.git"
      break
    elif [[ $input == 'n' || $input == 'N' ]]; then
      break
    else
      echo "  invalid input"
    fi
  done
}


###############################################################################
#  launch
###############################################################################
fn_detect_platform
fn_install_prerequisites
fn_set_directory
fn_configure_items
fn_execute_items
echo "[INF] ALL DONE!"
fn_install_authorized_keys
fn_generate_ssh_key

if command -v zsh &>/dev/null; then
  echo "[INF] starting in new zsh..."
  exec zsh
else
  echo "[INF] zsh not installed; staying in current shell."
fi
