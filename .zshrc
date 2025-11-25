# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  magic-enter
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


#############################################################################
# PATH
#############################################################################
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


#############################################################################
# Homebrew
#############################################################################
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi


#############################################################################
# basic
#############################################################################
alias c='clear'


#############################################################################
# navigation
#############################################################################
bindkey "^H" backward-word
bindkey "^J" backward-kill-word
bindkey "^L" forward-word


#############################################################################
# git
#############################################################################
alias gad='git add'
alias gap='git add -p'

alias gck='git checkout'
alias gcb='git checkout -b'

alias gcm='git commit --verbose'
alias gca='git commit --verbose --amend'

alias gdf='git diff'
alias gds='git diff --staged'
alias gdu='git diff "@{u}"'
alias gdo=fn_git_diff_open

alias gfh='git fetch'

alias glg='tig --all'
alias glo='git log --oneline'

alias gpl='git pull'
alias gpr='git pull --rebase'

alias gph='git push'
alias gpf='git push -f'
alias gpn='git push --set-upstream origin $(git branch --show-current)'

alias grt='git reset'
alias grh='git reset HEAD^'
alias grm='git reset --merge'
alias gro='git reset --hard "@{u}"'

alias grr='git restore'
alias grs='git restore --staged'

alias gsh='git stash'
alias gsp='git stash pop'
alias gsd='git stash drop'
alias gsl='git stash list -p'
alias gss='git stash show -p'

alias gst='git status'

alias gbs='git bisect start'
alias gbb='git bisect bad'
alias gbg='git bisect good'
alias gbr='git bisect reset'

alias gcp='git cherry-pick'

unalias gp
unalias gpu

function fn_git_diff_open() {(
  set -e;
  local BRANCH=$1;

  if [[ -z $BRANCH ]]; then
    local diff=($(git diff --name-only))

    if [[ ${#diff[@]} -eq 0 ]]; then
      >&2 echo "no diff found!"
      return -1
    fi

    local root=($(git rev-parse --show-toplevel))

    for ((i = 1; i <= ${#diff[@]}; i++)); do
      diff[$i]="${root}/${diff[$i]}"
      echo $diff[$i]
    done

    nvim ${diff[@]}
  else
    local diff=($(git diff --merge-base $BRANCH --name-only))

    if [[ ${#diff[@]} -eq 0 ]]; then
      >&2 echo "no diff found!"
      return -1
    fi

    local root=($(git rev-parse --show-toplevel))

    for ((i = 1; i <= ${#diff[@]}; i++)); do
      diff[$i]="${root}/${diff[$i]}"
    done

    nvim "+Gitsigns change_base $BRANCH true" ${diff[@]}
  fi
)}


#############################################################################
# Docker
#############################################################################
alias dps='sudo docker ps'
alias dlg='sudo docker logs -f'
alias dex='sudo docker exec -it'

alias dcu='sudo docker compose up -d'
alias dcd='sudo docker compose down'
alias dcs='sudo docker compose start'
alias dcp='sudo docker compose stop'


#############################################################################
# vi
#############################################################################
alias vi='nvim'


#############################################################################
# tmux
#############################################################################
alias tm='tmux -2'
alias ta='tmux attach'
alias f='fg'


#############################################################################
# build-essential
#############################################################################
alias make='make -j'


#############################################################################
# Rust
#############################################################################
if [ -d "$HOME/.cargo" ] ; then
  . "$HOME/.cargo/env"
fi


#############################################################################
# mise https://github.com/jdx/mise
#############################################################################
eval "$(~/.local/bin/mise activate zsh)"


#############################################################################
# rg https://github.com/BurntSushi/ripgrep
#############################################################################
alias rgh='rg --hidden --no-ignore --smart-case'


#############################################################################
# fzf https://github.com/junegunn/fzf
#############################################################################
export FZF_DEFAULT_COMMAND="fd --exclude={.git,.vscode,node_modules,target,debug} --type f"


#############################################################################
# eza https://github.com/eza-community/eza
#############################################################################
alias ls='eza --color-scale --time-style long-iso'
alias ll='eza --color-scale --time-style long-iso --long'
alias la='eza --color-scale --time-style long-iso --group --long --all'
alias lf='eza --color-scale --time-style long-iso --group --long --all --total-size'


#############################################################################
# zoxide https://github.com/ajeetdsouza/zoxide
#############################################################################
eval "$(zoxide init zsh --cmd j)"


#############################################################################
# zellij https://github.com/zellij-org/zellij
#############################################################################
alias z='zellij'
alias za='zellij attach'
alias zl='zellij list-sessions'


#############################################################################
# atuin https://github.com/atuinsh/atuin
#############################################################################
export ATUIN_CONFIG_DIR="$HOME/dotfiles/toolsets/atuin"
eval "$(atuin init zsh --disable-up-arrow)"


#############################################################################
# magic-enter
#############################################################################
MAGIC_ENTER_GIT_COMMAND='ll && echo && gst'
MAGIC_ENTER_OTHER_COMMAND='ll'


#############################################################################
# PER MACHINE
#############################################################################
[[ ! -f ~/.machine.zsh ]] || source ~/.machine.zsh
