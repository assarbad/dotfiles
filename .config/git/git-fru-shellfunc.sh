#!/usr/bin/env bash
# shellcheck disable=SC2059
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=sh:

function git_fru_impl
{
	if [[ ! -v WHENCE_CMD ]]; then
		local -a WHENCE_CMD
		if [[ -v BASH_VERSION ]]; then
			shopt -s extglob
			WHENCE_CMD=(builtin type -P)
		elif [[ -v ZSH_VERSION ]]; then
			setopt extendedglob
			WHENCE_CMD=(builtin whence -p)
		fi
	fi
	if ! [[ -v cR && -v cG && -v cB && -v cY && -v cW && -v cR_ && -v cG_ && -v cB_ && -v cY_ && -v cW_ && -v cZ ]]; then
		local cR="" cG="" cB="" cY="" cW="" cR_="" cG_="" cB_="" cY_="" cW_="" cZ=""
		readonly cR cG cB cY cW cR_ cG_ cB_ cY_ cW_ cZ
	fi
	for tool in env git; do
		if ! "${WHENCE_CMD[@]}" "$tool" > /dev/null 2>&1; then
			printf "${cR}ERROR:${cZ} ${cW}%s${cZ} does not seem to be installed.\n" "$tool"
			return 1
		fi
	done
	env LANG=C LC_ALL=C git fetch || return 1
	local UPSTREAM
	if UPSTREAM=$(env LANG=C LC_ALL=C git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then
		printf -- "Resetting ${cW}%s${cZ} to upstream ${cW}%s${cZ}\n" "$(env LANG=C LC_ALL=C git branch --show-current)" "$UPSTREAM"
		( set -x; ${DRY:+"echo"} env LANG=C LC_ALL=C git reset --hard '@{u}' )
	else
		printf -- "${cY}INFO:${cZ} no upstream branch set for the current branch; skipping ${cW}git reset --hard @{u}${cZ}\n"
		return 1
	fi
}

git_fru_impl "$@"
