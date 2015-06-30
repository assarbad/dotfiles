#!/usr/bin/env bash
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=sh:
# This script now drives the 'install' goal for the GNUmakefile
[[ -t 1 ]] && { cG="\e[1;32m"; cR="\e[1;31m"; cB="\e[1;34m"; cW="\e[1;37m"; cY="\e[1;33m"; cG_="\e[0;32m"; cR_="\e[0;31m"; cB_="\e[0;34m"; cW_="\e[0;37m"; cY_="\e[0;33m"; cZ="\e[0m"; export cR cG cB cY cW cR_ cG_ cB_ cY_ cW_ cZ; }
DOTFIROOT="$(pwd)"
MSPECROOT="$DOTFIROOT/machine-specific"
LOCALROOT="$HOME/.local/dotfiles"
TGTDIR=${TGTDIR:-$HOME}

function copy_newer
{
	local RELNAME="$1"
	local TGTBASEDIR="$2"
	local SRCBASEDIR="${3:-.}"
	local TGTNAME="$TGTBASEDIR/$RELNAME"
	local SRCNAME="$SRCBASEDIR/$RELNAME"
	# For relative names pointing to a subdirectory
	if [[ "$RELNAME" =~ "/" ]]; then
		mkdir -p "${TGTNAME%/*}" && touch -r "${SRCNAME%/*}" "${TGTNAME%/*}"
	fi
	# Copy if newer than target
	if [[ -n "$FORCE_COPY" ]] || [[ "$TGTNAME" -ot "$SRCNAME" ]]; then
		echo -en " ${cW}$RELNAME${cZ}"
		if cp "$SRCNAME" "$TGTNAME"; then
			echo -en " ${cW_}... copied${cZ}"
			if touch -r "$SRCNAME" "$TGTNAME" 2> /dev/null; then
				echo -e "${cW_}, set timestamp ${cG}[OK]${cZ}"
			else
				echo -e "${cW_}, ${cY}failed to set timestamp ${cG}[OK]${cZ}"
			fi
		else
			echo -e "  ${cR}copy failed${cZ}"
			exit 1
		fi
	fi
}

function handle_specific
{
	local SRCBASEDIR="$1"
	local KIND="$2"
	if [[ -d "$SRCBASEDIR/override" ]]; then
		echo -e "Copying ${cW}$KIND machine-specific${cZ} files ($SRCBASEDIR)"
		find "$SRCBASEDIR/override" -type f | sed 's/\.\///' | while read fname; do
			fname="${fname#$SRCBASEDIR/override/}"
			case "$fname" in
				GNUmakefile|README.rst)
					;;
				*)
					( FORCE_COPY=1 copy_newer "$fname" "$TGTDIR" "$SRCBASEDIR/override" )
					;;
			esac
		done
	else
		echo -e "No ${cW}$KIND machine-specific${cZ} files to process"
	fi
}

echo -e "Copying ${cW}base${cZ} files"
find . -type f | sed 's/\.\///;/^\.hg/d;/^machine-specific/d' | while read fname; do
	case "$fname" in
		GNUmakefile|README.rst|termclr256|append_payload|install.sh|hgrc.dotfiles|dotfile_installer.*|termcolor|.vim/.remove-obsolete.sh)
			;;
		*)
			copy_newer "$fname" "$TGTDIR"
			;;
	esac
done
handle_specific machine-specific "global"
handle_specific ~/.local/dotfiles "local"

# Fix the .gnupg file/folder permissions
if [[ -d "$TGTDIR/.gnupg" ]]; then
	chmod go= "$TGTDIR/.gnupg" "$TGTDIR/.gnupg/gpg.conf"
fi
exit 0
