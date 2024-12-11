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
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'preservim/nerdtree'
Plugin 'cohama/lexima.vim'
Plugin 'tpope/vim-commentary'
Plugin 'liuchengxu/vista.vim'
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
"   KEYMAPS
" #########################################################
nnoremap <C-k> <C-w>k " Switch window up
nnoremap <C-j> <C-w>j " Switch window down
nnoremap <C-h> <C-w>h " Switch window left
nnoremap <C-l> <C-w>l " Switch window right
nnoremap <C-p> <C-w>p " Jump to previous window

nnoremap tn :tabnew<CR> " Tab create new
nnoremap tx :tabclose<CR> " Tab close
nnoremap tl :tabnext<CR> " Tab next
nnoremap th :tabprev<CR> " Tab prev

" #########################################################
"   FZF
" #########################################################
let mapleader = " "
nnoremap <leader>fw :Rg<CR>
nnoremap <leader>ff :Files<CR>

" #########################################################
"   NERDTREE
" #########################################################
nnoremap <C-n> :NERDTreeToggle<CR>

" #########################################################
"   VISTA
" #########################################################
nnoremap tt :Vista!!<CR>

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
