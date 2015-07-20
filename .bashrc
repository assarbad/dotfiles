# Oliver's .bashrc - author: oliver@assarbad.net - may be freely copied.
# vim: set autoindent smartindent ts=4 sw=4 sts=4 filetype=sh:

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Because UID is readonly we cannot use the real thing, so let's fake it below ;)
MYUID=$UID

# On Windows the superuser has the UID (RID) 500, make it appear as root
[ -n "$COMSPEC" ] && [ $MYUID -eq 500 ] && { let MYUID=0; }

# Superuser will get a timeout for the shell if it's a remote shell via SSH
[ -n "$SSH_TTY" ] && [ $MYUID -eq 0 ] && export TMOUT=1800

export IGNOREEOF=2
[ -d "~/bin" ] && export PATH=$PATH:~/bin
# Remove empty entries
export PATH=${PATH//::/:}

if [ $MYUID -eq 0 ]; then
	export PS1='${debian_chroot:+($debian_chroot)}\[\033[1;31m\]${SHLVL:+[$SHLVL] }\u\[\033[1;34m\]@\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\$ '
	NEWPATH=''
	LASTDIR=''
	for dir in ${PATH//:/ }; do
		LASTDIR=$dir
		[ ! -d $dir ] && continue
		if [ "$(ls -lLd $dir | grep '^d.......w. ')" ]; then
			echo -e "\nDirectory $dir in PATH was world-writable, removed it from PATH!!!"
		elif [ "$NEWPATH" != "$dir" ]; then
			NEWPATH=$NEWPATH:$dir
		fi
	done
	# Remove the leading colon and export this as the path
	export PATH=${NEWPATH:1:${#NEWPATH}}
	unset LASTDIR
	unset LASTDIR
else
	export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]${SHLVL:+[$SHLVL] }\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '
fi

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=erasedups:ignorespace
export HISTIGNORE="&:ls:ll:l:[bf]g:exit:clear:vim:env:cd:cdf:pushf:ducks:psaux"
export HISTFILESIZE=3000

shopt -s autocd 2> /dev/null
shopt -s checkwinsize
shopt -s cdspell
shopt -s dotglob
shopt -s extglob

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# ANSI color codes
# ----------------
# Black       0;30     Dark Gray     1;30
# Blue        0;34     Light Blue    1;34
# Green       0;32     Light Green   1;32
# Cyan        0;36     Light Cyan    1;36
# Red         0;31     Light Red     1;31
# Purple      0;35     Light Purple  1;35
# Brown       0;33     Yellow        1;33
# Light Gray  0;37     White         1;37
umask 022

# Check for BASHRCDIR variable ...
[[ -d "${BASHRCDIR:-$HOME}" ]] || BASHRCDIR="$HOME"
BASHRCDIR=${BASHRCDIR:-$HOME}
# Alias definitions for ls. Figure out the feature set ...
if [[ "Linux" == "$(uname -s)" ]]; then
	MYLS_OPTIONS='--color=auto --time-style=long-iso'
	ls $MYLS_OPTIONS . > /dev/null 2>&1 || MYLS_OPTIONS='--color=auto'
	ls $MYLS_OPTIONS . > /dev/null 2>&1 || MYLS_OPTIONS=''
	[[ -n "$MYLS_OPTIONS" ]] && export LS_OPTIONS="$MYLS_OPTIONS"
	alias ls='ls $LS_OPTIONS'
	alias ll='ls $LS_OPTIONS -l'
	alias l='ls $LS_OPTIONS -all'
	unset MYLS_OPTIONS
else
	[[ "$(uname -s)" == "Darwin" ]] && export CLICOLOR=
	alias ll='ls -l'
	alias l='ls -ahl'
fi
# color hard links in cyan, but a little darker than soft links
if [[ -e "/etc/debian_version" ]] && type dircolors > /dev/null 2>&1; then
	# ls (from GNU coreutils) misbehaves in that it "succeeds" silently (exit code 0) although LS_COLORS is erroneous ... pain
	# ls: unrecognized prefix: mh
	# ls: unparsable value for LS_COLORS environment variable
	# However, this output doesn't seem to be shown when piping. How useless.
	command dircolors|command grep -q 'hl=' && export LS_COLORS="ln=01;36:hl=00;36"
	command dircolors|command grep -q 'mh=' && export LS_COLORS="ln=01;36:mh=00;36"
fi

# Convenience aliases
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'
alias mc='mc -c'
alias psaux='ps awwwux'
alias nano='nano -w'
alias currdate='date +"%Y-%m-%d %H:%M:%S"'
alias ssh='ssh -t'
alias list-ssh-sockets='find /tmp/ssh-* -name agent.\* -uid $(id -u) -exec ls -ahl {} \;'
[[ -f "$BASHRCDIR/.vimrc" ]] && VIMRC="-u \"$BASHRCDIR/.vimrc\""
(vim --help 2> /dev/null|grep -q '[[:space:]]*-p') && { alias vim="HOME=$BASHRCDIR vim -p -N -n -i NONE $VIMRC"; } || { alias vim="HOME=$BASHRCDIR vim -N -n -i NONE $VIMRC"; }
unset VIMRC

# Global Bash completion definitions
if [[ -n "$PS1" ]]; then
	for i in /etc/bash_completion /usr/local/share/bash-completion/bash_completion.sh; do
		[[ -f "$i" ]] && source "$i"
	done
fi

# Aliases in the external file overwrite those above.
[[ -f "$BASHRCDIR/.bash_aliases" ]] && source "$BASHRCDIR/.bash_aliases"

# On Windows we return early
[ -n "$COMSPEC" ] && return

# Load the SSH agent and if it's loaded already, add the default identity
if [[ -d "$HOME/.ssh" ]] && [[ -w "$HOME/.ssh" ]]; then
	SSHAGENT=$(which ssh-agent)
	SSHAGENTARGS="-s"
	USERSOCK="$HOME/.ssh/ssh_auth_sock"
	if [[ -z "$SSH_AUTH_SOCK" ]] && [[ -x "$SSHAGENT" ]]; then
		eval "$($SSHAGENT $SSHAGENTARGS)"
		[[ -n "$SSH_AGENT_PID" ]] && trap "kill $SSH_AGENT_PID" 0
		[[ -h "$USERSOCK" ]] && rm -f "$USERSOCK"
		ln -s "$SSH_AUTH_SOCK" "$USERSOCK"
	elif [[ "$SSH_AUTH_SOCK" == "$USERSOCK" ]] && [[ -h "$SSH_AUTH_SOCK" ]]; then
		echo "Not replacing existing symbolic link"
	elif [[ -S "$SSH_AUTH_SOCK" ]]; then
		echo "Using existing socket: '$SSH_AUTH_SOCK'"
		[[ -h "$USERSOCK" ]] && rm -f "$USERSOCK"
		ln -s "$SSH_AUTH_SOCK" "$USERSOCK"
	else
		SSH_AUTH_SOCK=$(find /tmp/ssh-* -type s -name agent.\* -uid $(id -u) 2> /dev/null|head -n 1)
		if [[ -n "$SSH_AUTH_SOCK" ]]; then
			echo "Found existing socket: $SSH_AUTH_SOCK"
			[[ -h "$USERSOCK" ]] && rm -f "$USERSOCK"
			ln -s "$SSH_AUTH_SOCK" "$USERSOCK"
		fi
	fi
	export SSH_AUTH_SOCK="$USERSOCK"
	unset USERSOCK
	unset SSHAGENT
	unset SSHAGENTARGS
fi

# Load additional settings
# NB: Worst-case scenario iff HOST is empty is that we source all files twice ...
BASHHOST="$(hostname -s 2>/dev/null)"
# hostname -s and -f are standard, -d is GNU only, it seems ... not on MacOS
BASHZONE="$(hostname -f 2>/dev/null)"; \
	BASHZONE="${BASHZONE//$BASHHOST/_}"
BASHSRCDIR="$BASHRCDIR/.bashrc.d"
if [[ -d "$BASHSRCDIR" ]]; then
	for f in $(find "$BASHSRCDIR" -maxdepth 1 -type f); do
		source "$f"
	done
	if [[ -d "$BASHSRCDIR/$BASHHOST" ]]; then
		for f in $(find "$BASHSRCDIR/$BASHHOST" -maxdepth 1 -type f); do
			source "$f"
		done
	fi
	if [[ -n "$BASHZONE" ]] && [[ -d "$BASHSRCDIR/$BASHZONE" ]]; then
		for f in $(find "$BASHSRCDIR/$BASHZONE" -maxdepth 1 -type f); do
			source "$f"
		done
	fi
fi
# beroot so we feel at home when assuming super-user rights
if [ $MYUID -eq 0 ]; then
	alias beroot='echo NOP'
else
	alias beroot="sudo su -"
fi
# alias beroot="sudo su -l root -c \"BASHRCDIR='$HOME' $(which bash) --rcfile $HOME/.bashrc\""
unset BASHZONE
unset BASHHOST
unset BASHSRCDIR
unset MYUID

# The prompt command will only show the current directory and username if the terminal type is "correct"
case "$TERM" in
	xterm|rvxt|screen-*|putty-*)
		export PROMPT_COMMAND='echo -ne "\033]0;${debian_chroot:+($debian_chroot)}${USER}@${HOSTNAME}: ${PWD}\007"'
		;;
esac

[[ -t 1 ]] && { cG="\e[1;32m"; cR="\e[1;31m"; cB="\e[1;34m"; cW="\e[1;37m"; cY="\e[1;33m"; cG_="\e[0;32m"; cR_="\e[0;31m"; cB_="\e[0;34m"; cW_="\e[0;37m"; cY_="\e[0;33m"; cZ="\e[0m"; export cR cG cB cY cW cR_ cG_ cB_ cY_ cW_ cZ; }
if type lsb_release > /dev/null 2>&1; then
	echo -e "${cG_}$(lsb_release -si) $(lsb_release -sr)${cZ} ${cR_}($(lsb_release -sc))${cZ}"
fi

function ducks
{
	if [[ -n "$1" && -d "$1" ]]; then
		du -cks "$1"/*|sort -rn|head -11|awk 'BEGIN { FS = " " } {printf "%-8.2f MiB\t", $1/1024; for(i=2; i<=NF; i++) {printf " %s", $i}; printf "\n"}'
	else
		du -cks *|sort -rn|head -11|awk 'BEGIN { FS = " " } {printf "%-8.2f MiB\t", $1/1024; for(i=2; i<=NF; i++) {printf " %s", $i}; printf "\n"}'
	fi
}

function pushf()
{
	local FOLDER1=$(for i in *"$1"*; do [[ -d "$i" ]] && { echo "$i"; break; }; done)
	pushd "$FOLDER1"/
}

function cdf()
{
	local FOLDER1=$(for i in *"$1"*; do [[ -d "$i" ]] && { echo "$i"; break; }; done)
	cd "$FOLDER1"/
}

function ccd()
{
	mkdir -p "$1" && cd "$1"
}

function __unlink_where_it_does_not_exist__
{
	(( $# != 0 )) || { echo "unlink: missing operand"; return; }
	(( $# > 1 )) && { shift; echo "unlink: extra operand(s) $@"; return; }
	rm "$1"
}
type unlink > /dev/null 2>&1 && unset __unlink_where_it_does_not_exist__ || alias unlink='__unlink_where_it_does_not_exist__'
