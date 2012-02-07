set nocompatible
set backspace=2
set background=dark
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
" set expandtab
set showmatch
set ruler
" set paste
syntax on
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
