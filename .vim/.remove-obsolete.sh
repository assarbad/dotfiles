#!/usr/bin/env bash
[[ -n "$1" ]] && [[ -d "$1" ]] && TGTDIR="$1"
[[ -n "$TGTDIR" ]] || { echo "TGTDIR environment variable not set."; exit 0; }
# First: directories
for i in \
	.vim/after \
	.vim/snippets \
	.vim/bundle/nerdcommenter \
	.vim/doc \
	.vim/color \
	.vim/colors \
	.vim/bundle/SimpylFold \
	.vim/bundle/vim-watchdog \
	.vim/bundle/vim-airline \
	.vim/bundle/supertab \
	.vim/bundle/vim-togglemouse \
	.vim/bundle/vim-nerdtree-tabs \
	.vim/bundle/colorscheme-molokai \
	.vim/bundle/colorscheme-solarized \
	.vim/ftplugin \
	.vim/plugin \
	.vim/templates \
	.vim/ftdetect \
	.vim/indent \
	.vim/bundle/vim-ansible-yaml \
	; do
	[[ -d "$TGTDIR/$i" ]] && { echo "Removing folder $i"; rm -rf "$TGTDIR/$i"; }
done
# Second: files
for i in \
	.vim/syntax/tmux.vim \
	.vim/syntax/nginx.vim \
	.vim/plugin/snipMate.vim \
	.vim/syntax/snippet.vim \
	.vim/plugin/watchdog.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/bookmark.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/creator.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/key_map.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/menu_controller.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/menu_item.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/opener.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/path.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/tree_dir_node.vim \
	.vim/bundle/nerdtree/plugin/nerdtree/tree_file_node.vim \
	.vim/autoload/snipMate.vim \
	.vim/bundle/vim-tmux/README.markdown \
	.vim/bundle/nerdtree/CHANGELOG \
	.vim/bundle/nerdtree/.github/ISSUE_TEMPLATE.md \
	; do
	[[ -f "$TGTDIR/$i" ]] && { echo "Removing file $i"; rm -f "$TGTDIR/$i"; }
done
exit 0
