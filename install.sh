#!/usr/bin/env bash
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=sh:
# This script now drives the 'install' goal for the GNUmakefile
[[ -t 1 ]] && { cG="\e[1;32m"; cR="\e[1;31m"; cB="\e[1;34m"; cW="\e[1;37m"; cY="\e[1;33m"; cG_="\e[0;32m"; cR_="\e[0;31m"; cB_="\e[0;34m"; cW_="\e[0;37m"; cY_="\e[0;33m"; cZ="\e[0m"; export cR cG cB cY cW cR_ cG_ cB_ cY_ cW_ cZ; }
DOTFIROOT="${DOTFIROOT:-$(pwd)}"
MSPECROOT="$DOTFIROOT/machine-specific"
LOCALROOT="$HOME/.local/dotfiles"
TGTDIR=${TGTDIR:-$HOME}

function override_and_append
{
	local RELNAME="$1"
	local TGTBASEDIR="$2"
	local SRCBASEDIR="$3"
	local TGTNAME="$4"
	local SRCNAME="$5"
	# Overwrite
	if [[ -f "$MSPECROOT/override/$RELNAME" ]] && [[ ! -f "$LOCALROOT/override/$RELNAME" ]]; then
		if cp "$MSPECROOT/override/$RELNAME" "$TGTNAME"; then
			echo -e "\t${cG}overwrite${cZ} ${cW}$RELNAME${cZ} from ${cW}${MSPECROOT#$HOME/}${cZ}"
			touch "$TGTNAME"
		fi
	fi
	if [[ -f "$LOCALROOT/override/$RELNAME" ]]; then
		if cp "$LOCALROOT/override/$RELNAME" "$TGTNAME"; then
			echo -e "\t${cG}overwrite${cZ} ${cW}$RELNAME${cZ} from ${cW}${LOCALROOT#$HOME/}${cZ}"
			touch "$TGTNAME"
		fi
	fi
	# Append
	if [[ -f "$MSPECROOT/append/$RELNAME" ]]; then
		if ( echo -e "###\n### ${MSPECROOT#$HOME/}/append/$RELNAME\n###" ; \
			cat "$MSPECROOT/append/$RELNAME" ) >> "$TGTNAME"; then
			echo -e "\t${cG}appending${cZ} ${cW}$RELNAME${cZ} from ${cW}${MSPECROOT#$HOME/}${cZ}"
		fi
	fi
	if [[ -f "$LOCALROOT/append/$RELNAME" ]]; then
		if ( echo -e "###\n### ${LOCALROOT#$HOME/}/append/$RELNAME\n###" ; \
			cat "$LOCALROOT/append/$RELNAME" ) >> "$TGTNAME"; then
			echo -e "\t${cG}appending${cZ} ${cW}$RELNAME${cZ} from ${cW}${LOCALROOT#$HOME/}${cZ}"
		fi
	fi
}

# Simply copies newer files from source to target (non-existing target means source is newer)
function copy_newer
{
	local RELNAME="$1"
	local TGTBASEDIR="$2"
	local SRCBASEDIR="${3:-.}"
	local TGTNAME="$TGTBASEDIR/$RELNAME"
	local SRCNAME="$SRCBASEDIR/$RELNAME"
	# For relative names pointing to a subdirectory
	if [[ "$RELNAME" =~ "/" ]]; then
		if [[ ! -d "${TGTNAME%/*}" ]]; then
			echo -e "  ${cW}${RELNAME%/*}${cZ}${cG}/${cZ}"
			mkdir -p "${TGTNAME%/*}" && touch -r "${SRCNAME%/*}" "${TGTNAME%/*}"
		fi
	fi
	local COPIED=0
	# Copy if newer than target
	if [[ "$TGTNAME" -ot "$SRCNAME" ]]; then
		echo -en "  ${cZ}${RELNAME%/*}/${cW}${RELNAME##*/}${cZ}"
		if cp "$SRCNAME" "$TGTNAME"; then
			echo -en " ${cW_}... copied${cZ}"
			let COPIED=COPIED+1
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
#	override_and_append "$RELNAME" "$TGTBASEDIR" "$SRCBASEDIR" "$TGTNAME" "$SRCNAME"
}

function handle_specific_overrides
{
	local SRCBASEDIR="$1"
	[[ -d "$SRCBASEDIR" ]] || return
	# Unconditional overrides
	if [[ -d "$SRCBASEDIR/override" ]]; then
		echo -e "Copying ${cW}machine-specific${cZ} files (${cW}${SRCBASEDIR#$HOME/}${cZ})"
		find "$SRCBASEDIR/override" -type f | sed 's/\.\///' | while read fname; do
			fname="${fname#$SRCBASEDIR/override/}"
			# Skip any of the files that are base files ...
			# We handle overrides in copy_newer() for those
			if [[ ! -f "$TGTDIR/$fname" ]]; then
				copy_newer "${fname#$SRCBASEDIR/override/}" "$TGTDIR" "$SRCBASEDIR/override"
			fi
		done
	fi
}

echo -e "Copying ${cW}base${cZ} files"
find . -type f | sed 's/\.\///;/^\.hg\//d;/^\.hgignore/d;/^machine-specific/d' | sort | while read fname; do
	case "$fname" in
		GNUmakefile|README.rst|termclr256|append_payload|install.sh|hgrc.dotfiles|dotfile_installer.*|termcolor|.vim/.remove-obsolete.sh)
			;;
		*)
			copy_newer "$fname" "$TGTDIR"
			;;
	esac
done
# Overrides
# handle_specific_overrides "$MSPECROOT"
# handle_specific_overrides "$LOCALROOT"

# Fix the .gnupg/.ssh file/folder permissions
for i in .ssh/authorized_keys .gnupg/gpg.conf; do
	if [[ -d "$TGTDIR/${i%/*}" ]]; then
		chmod go= "$TGTDIR/${i%/*}" "$TGTDIR/$i"
	fi
done
exit 0
