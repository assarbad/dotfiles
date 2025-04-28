set nocompatible    " this is Vim, not Vi

if empty(glob("$HOME/.vim/tmp"))
    silent !mkdir -p "$HOME/.vim/tmp"
endif
set directory=$HOME/.vim/tmp

set background=dark " using dark terminal make certain elements a little brighter ;)
set backspace=indent,eol,start " make backspace more convenient

" Indentation/tab related settings
set tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab autoindent
if has('smartindent')
	set smartindent
endif

" General settings
set nrformats=   " No octal numbers if leading 0
if has('cmdline_hist')
	set history=1000 " store lots of :cmdline history
endif
set modeline modelines=100
set undolevels=1000 " use many muchos levels of undo
set showmode     " show current mode down the bottom
set nowrap       " dont wrap lines
if has('linebreak')
	set linebreak    " wrap lines at convenient points
	set numberwidth=4 " width for line number gutter
endif
set wildmode=list:longest,full " make cmdline tab completion similar to bash
if has('wildignore')
	set wildignore=*.swp,*.bak,*.pyc,*.class,*.exe,*.pdb,*.dll,*.dbg
endif
if has('wildmenu')
	set wildmenu     " enable ctrl-n and ctrl-p to scroll through matches
endif
set scrolloff=3  " keep 3 lines when scrolling
set nobackup     " do not keep a backup file
set nowritebackup
"set noswapfile   " create no swap file
if has('title')
	set title        " change the terminal's title
endif
set visualbell   " don't beep visually
set noerrorbells " don't beep

if has('statusline')
	" status line and layout of the work space
	set laststatus=2
	" actual status line
	set statusline=\ %#StatusLineBufNum#\ %n\ %*\ 
	set statusline+=%f    " file name (as typed or relative)
	set statusline+=%#StatusLineModified#%m%* " modified flag: [+] or [-]
	set statusline+=%#StatusLineRdOnly#\ %r%* " readonly flag: [RO]
	set statusline+=%h    " help buffer flag
	set statusline+=%w    " preview window flag: [Preview]
	set statusline+=%#StatusLinePaste#%(\ %{&paste?'\[P\]':'\ '}\ %)%*  " paste flag: P 
	set statusline+=\ %=  " remainder is right-aligned
	set statusline+=%#StatusLineChar#%b/0x%02B\ %*
	set statusline+=%#StatusLineFormat#%({%{&fileformat}\|%{(&fenc==''?&enc:&fenc).((has('bomb')\ &&\ &bomb)?',BOM':'')}%k\|%{&filetype}}%)\ %*
	set statusline+=%#StatusLinePosition#%([%l,%v]\ [%p%%\ \@%o]\ %)%*
	" default status line setting
	highlight StatusLine         term=reverse cterm=NONE ctermbg=NONE  ctermfg=DarkGreen
	highlight StatusLineBufNum   term=reverse cterm=NONE ctermbg=White ctermfg=Black
	highlight StatusLineModified term=reverse cterm=NONE ctermbg=NONE  ctermfg=White
	highlight StatusLineRdOnly   term=reverse cterm=NONE ctermbg=NONE  ctermfg=DarkRed
	highlight StatusLinePaste    term=reverse cterm=NONE ctermbg=NONE  ctermfg=Yellow
	highlight StatusLineChar     term=reverse cterm=NONE ctermbg=NONE  ctermfg=White
	highlight StatusLineFormat   term=reverse cterm=NONE ctermbg=NONE  ctermfg=DarkGray
	highlight StatusLinePosition term=reverse cterm=NONE ctermbg=NONE  ctermfg=Gray
endif

set showmatch    " briefly jump to matching paren/bracket
set list
set number
if has('cmdline_info')
	set ruler        " show the cursor position all the time
endif

" search-related
set incsearch    " find the next match as we type the search
set hlsearch     " highlight searches by default
set ignorecase   " ignore case when searching
set smartcase    " ... but only when typing all lowercase, otherwise case-sensitive
" ... and how to get rid of the highlighted search matches? Like so:
nmap <leader>h :nohlsearch<CR>

" Follow and back in Vim help (from: Hacking Vim 7.2)
nmap <buffer> <CR> <C-]>
nmap <buffer> <BS> <C-T>

" Allow to toggle paste mode
nnoremap <F5> :set invpaste paste?<CR>
set pastetoggle=<F5>

filetype on | filetype plugin on | filetype indent on
if has('syntax')
	syntax on
	set spelllang=en  " use English for spellchecking
	set nospell       " but don't spellcheck by default
endif
if has("patch-7.4-399")
	set cryptmethod=blowfish2
endif
if version >= 700
	" https://github.com/tpope/vim-sensible
	runtime! bundle/vim-sensible/plugin/sensible.vim
	" Check for the undo persistence and if it has, disable it
	if has('undofile')
		set noundofile
	endif
	if has('windows')
		map  <F11>      :tabprevious <CR>
		map  <F12>      :tabnext     <CR>
		nmap <F11>      :tabprevious <CR>
		nmap <F12>      :tabnext     <CR>
		imap <F11> <C-o>:tabprevious <CR>
		imap <F12> <C-o>:tabnext     <CR>
	endif
	try
		" Only use pathogen on Vim 7.0 and up
		" (https://github.com/tpope/vim-pathogen)
		execute pathogen#infect()
	catch
	endtry
	if has('autocmd')
		autocmd FileType python inoremap :: <End>:
		if has('statusline')
			" now set it up to change the status line based on mode
			autocmd InsertLeave * highlight StatusLine term=reverse cterm=NONE ctermfg=DarkGreen ctermbg=NONE
			autocmd InsertEnter * highlight StatusLine term=reverse cterm=NONE ctermfg=DarkGrey  ctermbg=NONE
		endif
	endif
	" Toggle NERDTree
	map <leader>t :NERDTreeToggle<CR>
	" Template support, taken from Hacking Vim 7.2
	autocmd BufNewFile * silent! 0r $VIMHOME/templates/%:e.tpl
	" Shortcut for toggling line/column to show current cursor location
	if has('syntax')
		" Toggle highlighting cursor line and column
		function! ToggleCurline ()
			if &cursorline && &cursorcolumn
				set nocursorline nocursorcolumn
			else
				set cursorline cursorcolumn
			endif
		endfunction
		nmap <silent><C-c> :call ToggleCurline()<CR>
	endif
endif
" Allow saving of files as sudo when I forgot to start vim using sudo.
" http://stackoverflow.com/q/2600783
" cmap w!! %!sudo tee > /dev/null %
" http://unix.stackexchange.com/q/249221
cnoremap w!! call SudoSaveFile()

function! SudoSaveFile() abort
	execute (has('gui_running') ? '' : 'silent') 'write !env SUDO_EDITOR=tee sudo -e % >/dev/null'
	let &modified = v:shell_error
endfunction

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>:set number!<CR>
nmap <leader>w :set wrap!<CR>

set listchars=tab:>\ 
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
" nnoremap / /\v
" Make very magic mode the default for subst
" cnoremap s/ s/\v
if has('folding')
	set nofoldenable    " disable folding
endif

" Make an effort to tell Vim about capable terminals
if $COLORTERM == 'gnome-terminal'
	set t_Co=256
endif

" When detecting Tmux, ensure we can see highlighed lines in visual mode
if $TMUX != "" || $TMUX_PANE != ""
	highlight Visual term=reverse cterm=reverse ctermbg=DarkGrey ctermfg=NONE
endif

if has('diff') && &diff
	set diffopt=filler,iwhite,context:3
	nmap <leader>[ [c
	nmap <leader>] ]c
endif

" Only disable sleuth if it's loaded (no error if plugin absent)
if exists('g:loaded_sleuth')
	let g:sleuth_automatic = 0  " Disable line-ending detection
endif
