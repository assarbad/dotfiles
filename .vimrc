set nocompatible

set background=dark " using dark terminal make certain elements a little brighter ;)
set backspace=indent,eol,start " make backspace more convenient

" Indentation/tab related settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
set autoindent
set smartindent

" General settings
set history=1000 " store lots of :cmdline history
set showmode     " show current mode down the bottom
set nowrap       " dont wrap lines
set linebreak    " wrap lines at convenient points
set wildmode=list:longest,full " make cmdline tab completion similar to bash
set wildmenu     " enable ctrl-n and ctrl-p to scroll through matches
set scrolloff=3  " keep 3 lines when scrolling
set nobackup     " do not keep a backup file

" status line and layout of the work space
set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]
set showmatch
set list
set number
set ruler        " show the cursor position all the time
" default status line setting
highlight StatusLine term=reverse cterm=NONE ctermfg=2 ctermbg=NONE

" search-related
set incsearch    " find the next match as we type the search
set hlsearch     " highlight searches by default
set ignorecase   " ignore case when searching
set smartcase    " ... but only when typing all lowercase, otherwise case-sensitive
" ... and how to get rid of the highlighted search matches? Like so:
nmap <leader>h :nohlsearch<CR>

silent! runtime ftplugin/man.vim | filetype on | filetype plugin on | filetype indent on
syntax on
if version >= 700
	" https://github.com/tpope/vim-sensible
	runtime! plugin/sensible.vim
	" Only use pathogen on Vim 7.0 and up
	execute pathogen#infect()
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
" Allow saving of files as sudo when I forgot to start vim using sudo.
" http://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
cmap w!! %!sudo tee > /dev/null %
"command! -bar -nargs=0 SudoW :silent exe "write !sudo tee % >/dev/null" | silent edit!

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>:set number!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
if &encoding == 'utf-8'
	set listchars=tab:›\ ,eol:¬
else
	set listchars=tab:>\ 
endif
highlight NonText ctermfg=DarkGrey guifg=#4a4a59
highlight SpecialKey ctermfg=DarkGrey guifg=#4a4a59
" Matching parentheses should be highlighted
highlight MatchParen ctermbg=4
highlight LineNr term=reverse cterm=NONE ctermfg=DarkGrey ctermbg=NONE
" Highlight odd tabs in the middle of the line
match errorMsg /[^\t]\zs\t\+/

" Allow expanding to current active file directory (Practical Vim, page 95)
cnoremap <expr> %%  getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Use the leader for very magic search
nnoremap <leader>/ /\v
" Make very magic mode the default for subst
cnoremap s/ s/\v

" Make an effort to tell Vim about capable terminals
if $COLORTERM == 'gnome-terminal'
	set t_Co=256
endif

" Toggle NERDTree
map <leader>t :NERDTreeToggle<CR>
