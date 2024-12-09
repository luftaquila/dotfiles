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
set number
set smartindent
set smartcase

set hlsearch
set incsearch

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set shiftround

set scrolloff=5
set clipboard^=unnamed
set wildmode=longest:full,full
set mouse=a

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
