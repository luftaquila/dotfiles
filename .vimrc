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
Plugin 'ryanoasis/vim-devicons'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'preservim/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'PhilRunninger/nerdtree-visual-selection'
Plugin 'PhilRunninger/nerdtree-buffer-ops'
Plugin 'qpkorr/vim-bufkill'
Plugin 'schickling/vim-bufonly'
Plugin 'dhruvasagar/vim-table-mode'
Plugin 'bitc/vim-bad-whitespace'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/incsearch-fuzzy.vim'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
Plugin 'tpope/vim-commentary'
Plugin 'easymotion/vim-easymotion'
Plugin 'cohama/lexima.vim'
Plugin 'yegappan/taglist'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'wakatime/vim-wakatime'
Plugin 'tpope/vim-surround'

" to learn
Plugin 'mg979/vim-visual-multi'
call vundle#end()
filetype plugin indent on


" #########################################################
"   PROJECT SPECIFIC
" #########################################################
let cmd = 'source ~/dotfiles/scripts/rtworks/commands.sh;'

command -nargs=? B execute 'w | bo sp | terminal ++curwin ++rows=20 zsh -c "' . cmd . 'fn_rtworks_build <args>"'
command -nargs=1 M execute 'w | bo sp | terminal ++curwin ++rows=20 zsh -c "' . cmd . 'fn_rtworks_misra <args>"'
command -nargs=? L echom system('zsh -c "' . cmd . 'fn_rtworks_local_run"')


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
set laststatus=2
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


" #########################################################
"   THEMES
" #########################################################
set t_Co=256
set termguicolors

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_section_warning = ''
let g:airline_powerline_fonts = 1
let g:airline_theme = 'onedark'

colorscheme onehalfdark
hi Normal term=NONE cterm=NONE ctermbg=234 ctermfg=231 gui=NONE guibg=#1D1F21 guifg=#F8F8F2
hi Comment term=bold cterm=NONE ctermbg=bg ctermfg=244 gui=NONE guibg=bg guifg=#7C7C7C
hi LineNr term=underline cterm=NONE ctermbg=235 ctermfg=244 gui=NONE guibg=#232526 guifg=#7C7C7C
hi Search term=NONE cterm=NONE ctermbg=70 ctermfg=231 gui=NONE guibg=#5FAF00 guifg=#F8F8F2
hi IncSearch term=NONE cterm=NONE ctermbg=70 ctermfg=231 gui=NONE guibg=#5FAF00 guifg=#F8F8F2


" #########################################################
"   BUFFER, CURSOR, WINDOW, TAB CONTROL
" #########################################################
nmap <Enter> o<ESC>

nmap H :bp<CR>
nmap L :bn<CR>

nmap K :bd<CR>
command K bd!

nmap Q :q!
command Q execute 'qa!'
command O execute 'OpenSession'

nnoremap <C-c> <C-w>c
nmap <C-i> :horizontal wincmd =<CR>
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l
tmap <C-s> <C-w><C-w>

nmap <left> :vertical resize -5<CR>
nmap <right> :vertical resize +5<CR>
nmap <C-left> :res -5<CR>
nmap <C-right> :res +5<CR>

nmap <Tab>l :tabnext<CR>
nmap <Tab>h :tabprev<CR>
nmap <Tab>n :tabnew<CR>
nmap <Tab>c :tabclose<CR>

command VS execute 'vs' | norm <C-e><C-l>
cabbrev vs VS

command SP execute 'sp' | norm <C-e><C-j>
cabbrev sp SP

" #########################################################
"   CUSTOM COMMANDS
" #########################################################
" force write file
command SUDO execute 'w !sudo tee %'
cabbrev sudo SUDO

" generate new ctag file
command CTAGS execute '!ctags -R'
cabbrev ctags CTAGS

" change git diff base
command -nargs=1 G let g:gitgutter_diff_base = '<args>' | GitGutterAll

" CTRL+R in VISUAL mode to replace selected
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" CTRL+L in VISUAL mode to search selected
vnoremap <C-l> y/\V<C-R>=escape(@",'/\')<CR><CR>

cabbrev so so ~/.vimrc

cabbrev en enew


" #########################################################
"   TERMINALS
" #########################################################
" open shell window
command -nargs=? TERM execute 'bo sp | term ++curwin ++rows=' . (empty(<q-args>) ? 20 : <q-args>)
cabbrev term TERM


" #########################################################
"   SCRIPTS
" #########################################################
" edit from last position
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif


" #########################################################
"   NERDTree
" #########################################################
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
nmap tr :NERDTreeToggle<CR>


" #########################################################
"   taglist
" #########################################################
let Tlist_Use_Right_Window = 1
nmap tl :TlistToggle<CR>


" #########################################################
"   GIT GUTTER
" #########################################################
set signcolumn=yes
au VimEnter * GitGutterEnable
au VimEnter * set updatetime=100
autocmd ColorScheme * highlight! link SignColumn LineNr
let g:gitgutter_diff_base = 'HEAD'


" #########################################################
"   BAD WHITESPACE
" #########################################################
au VimEnter * ShowBadWhitespace


" #########################################################
"   INCSEARCH
" #########################################################
map /  <Plug>(incsearch-forward)
map g/  <Plug>(incsearch-stay)
map z/ <Plug>(incsearch-fuzzy-/)
map zg/ <Plug>(incsearch-fuzzy-stay)


" #########################################################
"   EASYMOTION
" #########################################################
let mapleader=','
map <Leader> <Plug>(easymotion-prefix)
map <Leader><Leader> <Plug>(easymotion-repeat)
nmap <Leader>f <Plug>(easymotion-overwin-f)
nmap <Leader>a <Plug>(easymotion-jumptoanywhere)


" #########################################################
"   SESSION.VIM
" #########################################################
set sessionoptions-=buffers
let g:session_autosave = 'yes'
let g:session_autoload = 'no'
let g:session_autosave_periodic = 1
let g:session_autosave_silent = 1
let g:session_default_overwrite = 1
let g:session_command_aliases = 1

" #########################################################
"   FZF
" #########################################################
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --glob='!{**/rtworks_packager/*,**/tags}' -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)

command -complete=tag -nargs=* R execute 'Rg <args>'
command -complete=tag -nargs=* T execute 'Tags <args>'
command -complete=file -nargs=* F execute 'Files <args>'

