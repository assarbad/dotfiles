set nocompatible
set backspace=2
set background=dark
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set showmatch
set ruler        " show the cursor position all the time
set history=1000 " store lots of :cmdline history
set showcmd      " show incomplete cmds down the bottom
set showmode     " show current mode down the bottom
set nowrap       " dont wrap lines
set linebreak    " wrap lines at convenient points
set wildmode=list:longest,full " make cmdline tab completion similar to bash
set wildmenu     " enable ctrl-n and ctrl-p to scroll thru matches
set scrolloff=3  " keep 3 lines when scrolling
set nobackup     " do not keep a backup file
" set title        " show title in console title bar
set wrap!        " turn off word wrapping
" set off the other paren
highlight MatchParen ctermbg=4
" quickly set comma or semicolon at the end of the string
inoremap ,, <End>,
inoremap ;; <End>;
" allow command mode with semi-colon, and comma
noremap ; :
noremap , ;
" toggle line numbers
nmap <C-N><C-N> :set invnumber<CR>
highlight LineNr term=reverse cterm=NONE ctermfg=DarkGrey ctermbg=NONE
set nonumber " but turn off line numbers by default
" status line
set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]
" search-related
set incsearch    " find the next match as we type the search
" set hlsearch     " highlight searches by default
set ignorecase   " ignore case when searching
set smartcase
" syntax highlighting
filetype on
filetype plugin on
filetype indent on
syntax on
" set expandtab
" set paste
if version >= 700
  nmap <C-t> :tabnew<CR>
  imap <C-t> <Esc>:tabnew<CR>
  map  <F11> :tabprevious <CR>
  map  <F12> :tabnext     <CR>
  nmap <F11> :tabprevious <CR>
  nmap <F12> :tabnext     <CR>
  imap <F11> :tabprevious <CR>
  imap <F12> :tabnext     <CR>
  set spl=en spell  " use English for spellchecking
  set nospell       " but don't spellcheck by default
  set numberwidth=4 " width for line number gutter
  au FileType python inoremap :: <End>:
  " now set it up to change the status line based on mode
  au InsertLeave * highlight StatusLine term=reverse cterm=NONE ctermfg=2 ctermbg=NONE
  au InsertEnter * highlight StatusLine term=reverse cterm=NONE ctermfg=DarkGrey ctermbg=NONE
endif
" default status line setting
highlight StatusLine term=reverse cterm=NONE ctermfg=2 ctermbg=NONE
