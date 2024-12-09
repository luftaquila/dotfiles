" #########################################################
"   VUNDLE
" #########################################################
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'sonph/onehalf', {'rtp': 'vim/'}
Plugin 'wakatime/vim-wakatime'
call vundle#end()
filetype plugin indent on

" #########################################################
"   DEFAULT SETTINGS
" #########################################################
syntax on
set ruler
set number
set encoding=utf-8
set autoindent
set smartindent
set smarttab
set smartcase
set ignorecase
set showcmd
set cursorline
set hlsearch
set incsearch
set autowrite
set autoread
set hidden
set history=1024
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set shiftround
set scrolloff=5
set clipboard^=unnamed
set shortmess+=I
set wildmode=longest:full,full
set ttyfast
set lazyredraw
set completeopt-=preview
set laststatus=0

" #########################################################
"   THEMES
" #########################################################
set t_Co=256
set termguicolors

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_section_warning = ''
let g:airline_theme = 'onedark'
let g:airline_section_z = '%l%#__restore__#%#__accent_bold#/%L%\(%2p%%)%\:%2v%#__restore__#'
let g:bufferline_show_bufnr = 0

colorscheme onehalfdark
