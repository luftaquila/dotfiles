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
set laststatus=3
set guicursor=i:block


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

nmap Q :q!<CR>
command Q execute 'qa!'
command O execute 'OpenSession'

nnoremap <C-c> <C-w>c
nmap <C-i> :horizontal wincmd =<CR>
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

nmap <C-p> <C-w>p
tnoremap <C-p> <C-\><C-o><C-w>p

nmap <left> :vertical resize -5<CR>
nmap <right> :vertical resize +5<CR>
nmap <C-left> :res -5<CR>
nmap <C-right> :res +5<CR>

nmap <Tab>l :tabnext<CR>
nmap <Tab>h :tabprev<CR>
nmap <Tab>n :tabnew<CR>
nmap <Tab>c :tabclose<CR>

command VS execute 'vs' | norm <C-e><C-l>
cnoreabbrev <expr> vs (getcmdtype() == ':' && getcmdline() == 'vs') ? 'VS' : 'vs'

command SP execute 'sp' | norm <C-e><C-j>
cnoreabbrev <expr> sp (getcmdtype() == ':' && getcmdline() == 'sp') ? 'SP' : 'sp'

" #########################################################
"   CUSTOM COMMANDS
" #########################################################
" force write file
command SUDO execute 'w !sudo tee %'
cnoreabbrev <expr> sudo (getcmdtype() == ':' && getcmdline() == 'sudo') ? 'SUDO' : 'sudo'

" generate new ctag file
command CTAGS execute '!ctags -R'
cnoreabbrev <expr> ctags (getcmdtype() == ':' && getcmdline() == 'ctags') ? 'CTAGS' : 'ctags'

" change git diff base
command -nargs=1 G let g:gitgutter_diff_base = '<args>' | GitGutterAll

" CTRL+F in VISUAL mode to search selected
vnoremap <C-f> y:<C-u>call setreg('s', ":R\<lt>Return><C-r>"", 'c')<CR>@s

" CTRL+H in VISUAL mode to replace selected
vnoremap <C-h> "hy:%s/<C-r>h//gc<left><left><left>

" repeat macro with space
nnoremap <Space> @q

cnoreabbrev <expr> en (getcmdtype() == ':' && getcmdline() == 'en') ? 'enew' : 'en'

cnoreabbrev <expr> vimrc (getcmdtype() == ':' && getcmdline() == 'vimrc') ? 'e ~/.config/nvim/init.vim' : 'vimrc'
cnoreabbrev <expr> zshrc (getcmdtype() == ':' && getcmdline() == 'zshrc') ? 'e ~/.zshrc' : 'zshrc'
cnoreabbrev <expr> machinerc (getcmdtype() == ':' && getcmdline() == 'machinerc') ? 'e ~/.machine.zsh' : 'machinerc'
cnoreabbrev <expr> cmd (getcmdtype() == ':' && getcmdline() == 'cmd') ? 'e ~/dotfiles/scripts/rtworks/commands.sh' : 'cmd'


" #########################################################
"   TERMINALS
" #########################################################
" open shell window
command -nargs=? TERMINAL execute 'bo sp | resize ' . (empty(<q-args>) ? 20 : <q-args>) . ' | terminal' | startinsert
cnoreabbrev <expr> te (getcmdtype() == ':' && getcmdline() == 'te') ? 'TERMINAL' : 'te'

autocmd BufWinEnter,WinEnter term://* startinsert | redraw
autocmd BufLeave term://* stopinsert | redraw

cnoreabbrev <expr> sh (getcmdtype() == ':' && getcmdline() == 'sh') ? 'normal <C-z>' : 'sh'

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
let fzf_exclude = '**/rtworks_packager/*,**/tags,**/node_modules/*,**/target/debug/*'

command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --glob='!{" . fzf_exclude . "}' -- ".shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

command -complete=tag -nargs=* R execute 'Rg <args>'
command -complete=tag -nargs=* T execute 'Tags <args>'
command -complete=file -nargs=* F execute 'Files <args>'


" #########################################################
"   PROJECT SPECIFIC
" #########################################################
let cmd = 'source ~/dotfiles/scripts/rtworks/commands.sh;'

command -nargs=? B execute 'w | bo sp | resize 20 | terminal zsh -c "' . cmd . 'fn_rtworks_build <args>"' | normal i
command -nargs=? E execute 'w | bo sp | resize 20 | terminal zsh -c "' . cmd . 'fn_rtworks_local_execute_fast <args>"' | normal i
command -nargs=1 M execute 'w | bo sp | resize 20 | terminal zsh -c "' . cmd . 'fn_rtworks_misra <args>"' | normal i
command -nargs=? L echom system('zsh -c "' . cmd . 'fn_rtworks_local_run"')

nmap <C-b> :B l4<CR>
nmap <C-f> :E<CR>

