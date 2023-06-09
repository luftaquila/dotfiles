" #########################################################
"   VUNDLE
" #########################################################
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
Plugin 'schickling/vim-bufonly'
Plugin 'dhruvasagar/vim-table-mode'
Plugin 'bitc/vim-bad-whitespace'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/incsearch-fuzzy.vim'
Plugin 'tpope/vim-commentary'
Plugin 'easymotion/vim-easymotion'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
Plugin 'yegappan/taglist'

" to learn
Plugin 'tpope/vim-surround'
Plugin 'mg979/vim-visual-multi'
Plugin 'jiangmiao/auto-pairs'
Plugin 'ycm-core/YouCompleteMe'

" disabled
" Plugin 'kien/ctrlp.vim'
call vundle#end()
filetype plugin indent on


" #########################################################
"   PROJECT SPECIFIC
" #########################################################
:command R !(>&2 ~/dotfiles/scripts/rst) > /dev/null 2>&1;
:command -nargs=? D :execute 'w' | :execute 'bo sp' | :execute 'terminal ++curwin ++rows=20 zsh -c "(>&2 ~/dotfiles/scripts/rst) > /dev/null 2>&1 & (cd ~/workspace/rtworks/builder/; ./build.py -gv<args>l4);"'
:command -nargs=? B :execute 'w' | :execute 'bo sp' | :execute 'terminal ++curwin ++rows=20 zsh -c "(>&2 ~/dotfiles/scripts/rst) > /dev/null 2>&1 & (cd ~/workspace/rtworks/builder/; ./build.py -gv<args>);"'

:command -nargs=1 M :execute 'bo sp' | :execute 'terminal ++curwin ++rows=20 zsh -c "cd ~/workspace/rtworks/<args>/build; pwd; cmake -DBSP=t2080rdb -DUSE_MISRA_CHECKER=1 ..; make check-misra > tmp_check-misra.txt; ../misc/scripts/report_misra.sh > tmp_report_misra.txt; cat tmp_report_misra.txt"'


" #########################################################
"   DEFAULT SETTINGS
" #########################################################
syntax on
set number
set autoindent
set smartindent
set smarttab
set ruler
set showcmd
set cursorline
set laststatus=2
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
set clipboard^=unnamed
set shortmess+=I
set wildmode=longest:full,full
set ttyfast
set lazyredraw


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
"   CURSOR, WINDOW, TAB CONTROL
" #########################################################
nmap <Enter> o<ESC>

nmap H :bp<CR>
nmap L :bn<CR>
nmap K :bd<CR>
nmap Q :BD<CR>
command K :BD!
command Q :q!

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

:command VS :execute 'vs' | :norm <C-e><C-l>
:cabbrev vs VS

:command US :execute 'bo sp' | :res 15
:cabbrev us US


" #########################################################
"   CUSTOM COMMANDS
" #########################################################
:command -complete=tag -nargs=* RG :execute 'Rg <args>'
:cabbrev rg RG

:command -complete=tag -nargs=* TAGS :execute 'Tags <args>'
:cabbrev tag TAGS

:command -complete=file -nargs=* F :execute 'Files <args>'

" force write file
:command SUDO :execute 'w !sudo tee %'
:cabbrev sudo SUDO

" generate new ctag file
:command CTAGS :execute '!ctags -R'
:cabbrev ctags CTAGS

" change git diff base
:command -nargs=1 G :let g:gitgutter_diff_base = '<args>' | :GitGutterAll

" CTRL+R in VISUAL mode to replace selected
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" CTRL+F in VISUAL mode to search selected
vnoremap <C-f> y/\V<C-R>=escape(@",'/\')<CR><CR>

:cabbrev so so ~/.vimrc

:cabbrev en enew


" #########################################################
"   TERMINALS
" #########################################################
" open shell window
:command -nargs=? TERM :execute 'bo sp' | :execute 'term ++curwin ++rows=' . (empty(<q-args>) ? 20 : <q-args>)
:cabbrev term TERM

" execute shell in new buffer
:command -complete=file -nargs=+ E :execute 'bo sp' | :execute 'terminal ++curwin ++rows=20 zsh -c "<args>"'

" show shell output in new buffer
function! s:ExecuteInShell(command)
  let command = join(map(split(a:command), 'expand(v:val)'))
  let winnr = bufwinnr('^' . command . '$')
  silent! execute  winnr < 0 ? 'botright vnew ' . fnameescape(command) : winnr . 'wincmd w'
  setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
  echo 'executing ' . command . '...'
  silent! execute 'silent %!'. command
  silent! execute 'resize '
  silent! redraw
  silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
  silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>'
  echo 'command ' . command . ' executed.'
endfunction
command! -complete=shellcmd -nargs=+ SHELL call s:ExecuteInShell(<q-args>)
:cabbrev ss SHELL


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
"   RAINBOW PARENTHESES
" #########################################################
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces


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
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
map z/ <Plug>(incsearch-fuzzy-/)
map z? <Plug>(incsearch-fuzzy-?)
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
:command OS :OpenSession


