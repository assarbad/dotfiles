autocmd BufNewFile,BufRead {.,}tmux.conf{.*,} setlocal filetype=tmux
autocmd BufNewFile,BufRead {.,}tmux.conf{.*,} setlocal commentstring=#\ %s
