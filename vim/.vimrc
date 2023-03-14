set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'wakatime/vim-wakatime'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'sonph/onehalf', {'rtp': 'vim/'}
Plugin 'preservim/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'PhilRunninger/nerdtree-visual-selection'
Plugin 'PhilRunninger/nerdtree-buffer-ops'
Plugin 'airblade/vim-gitgutter'
Plugin 'ryanoasis/vim-devicons'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'qpkorr/vim-bufkill'
Plugin 'dhruvasagar/vim-table-mode'
Plugin 'bitc/vim-bad-whitespace'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/incsearch-fuzzy.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-commentary'
Plugin 'easymotion/vim-easymotion'
Plugin 'schickling/vim-bufonly'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'

Plugin 'tpope/vim-surround'
Plugin 'mg979/vim-visual-multi'
Plugin 'jiangmiao/auto-pairs'
Plugin 'sjl/gundo.vim'
" Plugin 'fholgado/minibufexpl.vim'
call vundle#end()
filetype plugin indent on

filetype plugin on
filetype on

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_section_warning = ''
let g:airline_powerline_fonts = 1
let g:airline_theme = 'onedark'

let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'

nmap tr :NERDTreeToggle<CR>

syntax on
set number
set autoindent
set smartindent
set smarttab
set ruler
set showcmd
set cursorline
set laststatus=2

colorscheme onehalfdark
hi Normal term=NONE cterm=NONE ctermbg=234 ctermfg=231 gui=NONE guibg=#1D1F21 guifg=#F8F8F2
hi Comment term=bold cterm=NONE ctermbg=bg ctermfg=244 gui=NONE guibg=bg guifg=#7C7C7C
hi LineNr term=underline cterm=NONE ctermbg=235 ctermfg=244 gui=NONE guibg=#232526 guifg=#7C7C7C
set t_Co=256
set termguicolors

set hlsearch
set showmatch
set incsearch
set ignorecase
set smartcase

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
" set colorcolumn=80

set clipboard^=unnamed

nmap <Enter> o<ESC>
nmap <S-Enter> O<ESC>

nmap H :bp<CR>
nmap L :bn<CR>
nmap R :BufOnly<CR>
nmap K :BD<CR>

nnoremap <C-c> <C-w>c
nmap <C-u> :horizontal wincmd =<CR>
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

nmap <left> :vertical resize -5<CR>
nmap <right> :vertical resize +5<CR>
nmap <C-left> :res -5<CR>
nmap <C-right> :res +5<CR>

nmap <Tab>l :tabnext<CR>
nmap <Tab>h :tabprev<CR>
nmap <Tab>n :tabnew<CR>
nmap <Tab>c :tabclose<CR>

" edit from last position
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif

:command B !cd ~/workspace/builder/; python build.py
:command M !cd build; cmake -DBSP=stm32h743i-eval2 -DUSE_MISRA_CHECKER=1 ..; make check-misra > tmp_check-misra.txt; ../misc/scripts/report_misra.sh > tmp_report_misra.txt; bat tmp_report_misra.txt

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

set signcolumn=yes
au VimEnter * GitGutterEnable
au VimEnter * set updatetime=100
autocmd ColorScheme * highlight! link SignColumn LineNr

au VimEnter * ShowBadWhitespace

map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
map z/ <Plug>(incsearch-fuzzy-/)
map z? <Plug>(incsearch-fuzzy-?)
map zg/ <Plug>(incsearch-fuzzy-stay)

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'

let mapleader=','
map <Leader> <Plug>(easymotion-prefix)
map <Leader><Leader> <Plug>(easymotion-repeat)
nmap <Leader>f <Plug>(easymotion-overwin-f)
nmap <Leader>a <Plug>(easymotion-jumptoanywhere)

:command VS :execute 'vs' | :norm <C-e><C-l>
:cabbrev vs VS

:command US :execute 'bo sp' | :res 15
:cabbrev us US

:command TERM :execute 'bo sp' | :res 20 | :term ++curwin
:cabbrev term TERM

:command SUDO :execute 'w !sudo tee %'
:cabbrev sudo SUDO

:cabbrev rg Rg
:cabbrev tag Tags

:command TAGEN :execute '!ctags -R'
:cabbrev tagen TAGEN

set sessionoptions-=buffers
let g:session_autosave = 'yes'
let g:session_autoload = 'no'
let g:session_autosave_periodic = 1
let g:session_autosave_silent = 1
let g:session_command_aliases = 1
