set nocompatible
set backspace=2
set background=dark
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set showmatch
set ruler        " show the cursor position all the time
set history=1000 "store lots of :cmdline history
set showcmd      "show incomplete cmds down the bottom
set showmode     "show current mode down the bottom
set nowrap       "dont wrap lines
set linebreak    "wrap lines at convenient points
set wildmode=list:longest "make cmdline tab completion similar to bash
set wildmenu     "enable ctrl-n and ctrl-p to scroll thru matches
set scrolloff=3  " keep 3 lines when scrolling
set nobackup     " do not keep a backup file
" set title        " show title in console title bar
set wrap!        " turn off word wrapping
" Quickly set comma or semicolon at the end of the string
inoremap ,, <End>,
inoremap ;; <End>;
au FileType python inoremap :: <End>:
" search-related
set incsearch    "find the next match as we type the search
set hlsearch     "highlight searches by default
set ignorecase   " ignore case when searching
set smartcase
filetype plugin on
filetype indent on
syntax on
" set expandtab
" set paste
if version >= 700
:nmap <C-t> :tabnew<CR>
:imap <C-t> <Esc>:tabnew<CR>
:map  <F11> :tabprevious <CR>
:map  <F12> :tabnext     <CR>
:nmap <F11> :tabprevious <CR>
:nmap <F12> :tabnext     <CR>
:imap <F11> :tabprevious <CR>
:imap <F12> :tabnext     <CR>
endif
