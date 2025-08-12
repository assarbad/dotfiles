#!/usr/bin/env bash
# shellcheck disable=SC2059
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=sh:
declare -ir DEFAULT_NUMBER_OF_REFLOG_ITEMS=50
shopt -s extglob

function select_reflog_branch
{
	# Relevant operation markers (probably incomplete)
	# 'Branch'
	# 'checkout'
	# 'cherry-pick'
	# 'commit (amend)'
	# 'commit (cherry-pick)'
	# 'commit'
	# 'pull --all'
	# 'pull'
	# 'rebase (abort)'
	# 'rebase (continue)'
	# 'rebase (edit)'
	# 'rebase (finish)'
	# 'rebase (pick)'
	# 'rebase (reword)'
	# 'rebase (squash)'
	# 'rebase (start)'
	# 'rebase'
	# 'reset'
	# 'revert'
	local line refkey auxvar from to _ lastline
	local -ir NUM="${1:-$DEFAULT_NUMBER_OF_REFLOG_ITEMS}"
	local -A SEEN_REFS
	local -a PRESENTABLE_OUTPUT_LINES
	# Parse and filter the git reflog output
	while read -r commit date reflogselector operation remainder; do
		operation="${operation:1:-1}"
		printf -v line "%s %s %s %s: %s" "$commit" "$date" "$reflogselector" "$operation" "$remainder"
		refkey="$operation:$commit"
		if ! LANG=C LC_ALL=C git show --oneline "$commit" -- > /dev/null 2>&1; then
			continue
		fi
		case "$operation" in
			reset | checkout | rebase_finish | rebase_start)
				if [[ ! -v SEEN_REFS[$refkey] ]]; then
					SEEN_REFS[$refkey]="$line"
					case "$operation" in
						reset)
							read -r _ _ auxvar < <(echo -n "$remainder") # moving to ...
							printf -v presentable_line "${cB}%s${cZ} ${cY}%10s${cZ} %8s ${cW}%s${cZ} [${cG}%s${cZ}]" "$commit" "$reflogselector" "$operation" "$auxvar" "$date"
							PRESENTABLE_OUTPUT_LINES+=("$presentable_line")
							;;
						checkout)
							read -r _ _ from _ to < <(echo -n "$remainder") # moving from ... to ...
							printf -v presentable_line "${cB}%s${cZ} ${cY}%10s${cZ} %8s ${cW}%s${cZ} (from ${cW_}%s${cZ}) [${cG}%s${cZ}]" "$commit" "$reflogselector" "$operation" "$to" "$from" "$date"
							PRESENTABLE_OUTPUT_LINES+=("$presentable_line")
							;;
						rebase_finish)
							read -r _ _ auxvar < <(echo -n "$remainder") # returning to ...
							operation="rebased"
							printf -v presentable_line "${cB}%s${cZ} ${cY}%10s${cZ} %8s ${cW}%s${cZ} [${cG}%s${cZ}]" "$commit" "$reflogselector" "$operation" "${auxvar#refs/heads/}" "$date"
							PRESENTABLE_OUTPUT_LINES+=("$presentable_line")
							;;
						rebase_start)
							read -r _ auxvar < <(echo -n "$remainder") # checkout ...
							operation="rebasing"
							printf -v presentable_line "${cB}%s${cZ} ${cY}%10s${cZ} %8s ${cW}%s${cZ} [${cG}%s${cZ}]" "$commit" "$reflogselector" "$operation" "$auxvar" "$date"
							PRESENTABLE_OUTPUT_LINES+=("$presentable_line")
							;;
						*)
							;;
					esac
					if [[ "$lastline" != "${PRESENTABLE_OUTPUT_LINES[-1]}" ]]; then
						lastline="${PRESENTABLE_OUTPUT_LINES[-1]}"
						printf "$lastline\n"
					fi
				fi
				;;
		esac
	# Read the git reflog output into an array, by using :%gs as format specifier we allow the subsequent sed to work more efficiently, allowing us to transform "operation" markers into markers without blank spaces
	# ... also, filter out a bunch of operations that aren't interesting to us
	done \
		< <(
			env LANG=C LC_ALL=C git reflog --pretty=format:'%h %aI %gd :%gs' \
				| sed -Ee 's/:(rebase|commit) \(([^\)]*)\):/:\1_\2:/g; s|:pull --all:|:pull_all:|g; /:(pull|pull_all|commit|commit_amend|rebase_pick|rebase_abort|rebase_edit|rebase_squash|rebase_reword|Branch):/d'
		) \
		| head -n $NUM \
		| sk --ansi --no-multi --header 'Select recently used branch from reflog' -p 'RECENT BRANCH: ' --preview='git show -s --pretty=medium --color=always {1} --' --preview-window=right:40% \
		| awk '{print $4}'
}

function git_back_impl
{
	local -i NUM="${1:-$DEFAULT_NUMBER_OF_REFLOG_ITEMS}"
	if ! [[ -v cR && -v cG && -v cB && -v cY && -v cW && -v cR_ && -v cG_ && -v cB_ && -v cY_ && -v cW_ && -v cZ ]]; then
		local cR="" cG="" cB="" cY="" cW="" cR_="" cG_="" cB_="" cY_="" cW_="" cZ=""
		if [[ ($- == *i* || -t 1 ) && ! -v BATS_VERSION ]]; then # No coloring during test execution
			cG="\e[1;32m" cR="\e[1;31m" cB="\e[1;34m" cW="\e[1;37m" cY="\e[1;33m" cG_="\e[0;32m" cR_="\e[0;31m" cB_="\e[0;34m" cW_="\e[0;37m" cY_="\e[0;33m" cZ="\e[0m"
		fi
		readonly cR cG cB cY cW cR_ cG_ cB_ cY_ cW_ cZ
	fi
	for tool in awk env git head sed sk; do 
		if ! type -p "$tool" > /dev/null 2>&1; then
			printf "${cR}ERROR:${cZ} ${cW}%s${cZ} does not seem to be installed.\n" "$tool"
			return 1
		fi
	done
	case "$NUM" in
		*[!0-9]*)
			printf "${cY}WARNING:${cZ} number of results '${cW}%s${cZ}' not an integer (the number of branches to show). Using default ${cW}%s${cZ}.\n" "$NUM" "$DEFAULT_NUMBER_OF_REFLOG_ITEMS" >&2
			NUM="$DEFAULT_NUMBER_OF_REFLOG_ITEMS"
			;;
	esac
	if ((NUM < 1)); then
		printf "${cY}WARNING:${cZ} number of results '${cW}%s${cZ}' is smaller than one. Using default ${cW}%s${cZ}.\n" "$NUM" "$DEFAULT_NUMBER_OF_REFLOG_ITEMS" >&2
		NUM="$DEFAULT_NUMBER_OF_REFLOG_ITEMS"
	fi
	local TGTBRNCH
	TGTBRNCH=$(select_reflog_branch "$NUM")
	if [[ $? -ne 0 || -z "$TGTBRNCH" ]]; then
		printf "${cW}INFO:${cZ} error exit status from branch selection logic or empty selection (no branch, won't switch)\n"
		return 1
	fi
	( set -x; ${DRY:+"echo"} LANG=C LC_ALL=C git switch "$TGTBRNCH" )
}

git_back_impl "$@"
