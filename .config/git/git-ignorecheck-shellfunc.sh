#!/usr/bin/env bash
# shellcheck disable=SC2059
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=sh:

function git_ignorecheck_impl
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
	local -a TRACKED_BUT_IGNORED
	# --exclude-per-directory=.gitignore restricts matching to .gitignore files found
	# while walking the tree (any directory), deliberately leaving out core.excludesfile
	# and $GIT_DIR/info/exclude so only worktree-local .gitignore rules are considered.
	while IFS= read -r -d '' path; do
		TRACKED_BUT_IGNORED+=("$path")
	done < <(env LANG=C LC_ALL=C git ls-files -z -i -c --exclude-per-directory=.gitignore -- "$@")
	if ((${#TRACKED_BUT_IGNORED[@]} == 0)); then
		printf "${cG}OK:${cZ} no tracked files are matched by a .gitignore rule.\n"
		return 0
	fi
	printf "${cY}WARNING:${cZ} ${cW}%d${cZ} tracked file(s) are also matched by a .gitignore rule:\n" "${#TRACKED_BUT_IGNORED[@]}"
	local path rule
	for path in "${TRACKED_BUT_IGNORED[@]}"; do
		if rule=$(env LANG=C LC_ALL=C git check-ignore -v -- "$path" 2>/dev/null); then
			printf -- "    ${cW}%s${cZ}  [${cR}%s${cZ}]\n" "$path" "$rule"
		else
			printf -- "    ${cW}%s${cZ}  [${cY}ignored via non-.gitignore exclude; not shown${cZ}]\n" "$path"
		fi
	done
	return 1
}

git_ignorecheck_impl "$@"
