#!/usr/bin/env bash
[[ -n "$1" ]] && [[ -d "$1" ]] && TGTDIR="$1"
[[ -n "$TGTDIR" ]] || { echo "TGTDIR environment variable not set."; exit 0; }
# First: directories
for i in .vim/after .vim/snippets .vim/bundle/nerdcommenter .vim/doc .vim/bundle/SimpylFold .vim/bundle/vim-watchdog .vim/bundle/vim-airline .vim/ftplugin .vim/plugin; do
	[[ -d "$TGTDIR/$i" ]] && { echo "Removing folder $i"; rm -rf "$TGTDIR/$i"; }
done
# Second: files
for i in .vim/syntax/tmux.vim .vim/plugin/snipMate.vim .vim/syntax/snippet.vim .vim/plugin/watchdog.vim .vim/bundle/nerdtree/plugin/nerdtree/bookmark.vim .vim/bundle/nerdtree/plugin/nerdtree/creator.vim .vim/bundle/nerdtree/plugin/nerdtree/key_map.vim .vim/bundle/nerdtree/plugin/nerdtree/menu_controller.vim .vim/bundle/nerdtree/plugin/nerdtree/menu_item.vim .vim/bundle/nerdtree/plugin/nerdtree/opener.vim .vim/bundle/nerdtree/plugin/nerdtree/path.vim .vim/bundle/nerdtree/plugin/nerdtree/tree_dir_node.vim .vim/bundle/nerdtree/plugin/nerdtree/tree_file_node.vim .vim/autoload/snipMate.vim .vim/bundle/vim-tmux/README.markdown; do
	[[ -f "$TGTDIR/$i" ]] && { echo "Removing file $i"; rm -f "$TGTDIR/$i"; }
done
exit 0
