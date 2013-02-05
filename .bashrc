# Oliver's .bashrc - author: oliver@assarbad.net - may be freely copied.
# $Id$
# vim: set autoindent smartindent ts=4 sw=4 sts=4 filetype=sh:

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# The prompt command will only show the current directory and username if the terminal type is "correct"
[ "$TERM" == "xterm" -o "$TERM" == "rvxt" ] && export PROMPT_COMMAND='echo -ne "\033]0;${debian_chroot:+($debian_chroot)}${USER}@${HOSTNAME}: ${PWD}\007"'

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
else
	export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]${SHLVL:+[$SHLVL] }\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '
fi

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=erasedups:ignorespace
export HISTIGNORE="&:ls:ll:l:[bf]g:exit:clear:vim:env:cd:cdf:pushf:ducks:psaux"
export HISTFILESIZE=3000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s cdspell
shopt -s dotglob

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
else
	[[ "$(uname -s)" == "Darwin" ]] && export CLICOLOR=
	alias ll='ls -l'
	alias l='ls -ahl'
fi
# color hard links in cyan, but a little darker than soft links
if [[ -e "/etc/debian_version" ]]; then
	LS_COLORS="ln=01;36:mh=00;36"
	ls -ahl > /dev/null 2>&1 || LS_COLORS="ln=01;36:hl=00;36"
	export LS_COLORS
fi
# beroot so we feel at home when assuming super-user rights
if [ $MYUID -eq 0 ]; then
	alias beroot='echo You are root already, silly!'
else
	alias beroot="sudo su -l root -c \"BASHRCDIR='$HOME' $(which bash) --rcfile $HOME/.bashrc\""
fi

# Convenience aliases
alias ..='cd ..'
alias -- -='cd -'
alias mc='mc -c'
alias psaux='ps awwwux'
alias nano='nano -w'
alias currdate='date +"%Y-%m-%d %H:%M:%S"'
alias ssh='ssh -at'
alias list-ssh-sockets='find /tmp/ssh-* -name agent.\* -uid $(id -u) -exec ls -ahl {} \;'
[[ -f "$BASHRCDIR/.vimrc" ]] && VIMRC="-u \"$BASHRCDIR/.vimrc\""
(vim --help 2> /dev/null|grep -q '[[:space:]]*-p') && { alias vim="vim -p -N -n -i NONE $VIMRC"; } || { alias vim="vim -N -n -i NONE $VIMRC"; }
unset VIMRC

# Aliases in the external file overwrite those above.
[[ -f "$BASHRCDIR/.bash_aliases" ]] && source "$BASHRCDIR/.bash_aliases"

# Global Bash completion definitions
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# Load the SSH agent and if it's loaded already, add the default identity
SSHAGENT=$(which ssh-agent)
SSHAGENTARGS="-s"
if [[ -z "$SSH_AUTH_SOCK" ]] && [[ -x "$SSHAGENT" ]]; then
	eval "$($SSHAGENT $SSHAGENTARGS|grep -v ^echo)"
	[[ -n "$SSH_AGENT_PID" ]] && { trap "kill $SSH_AGENT_PID" 0; ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"; }
else
	SSH_AUTH_SOCK=$(find /tmp/ssh-* -name agent.\* -uid $(id -u) 2> /dev/null|head -n 1)
	export SSH_AUTH_SOCK
fi
if [[ -n "$SSH_AUTH_SOCK" ]]; then
	ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock" && export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"
fi

# Load additional settings (NOTE: does not allow blanks in names of files within that folder)
if [[ -d "$BASHRCDIR/.bashrc.d" ]]; then
	for f in `command ls -A "$BASHRCDIR/.bashrc.d"`; do
		source "$BASHRCDIR/.bashrc.d/$f"
	done
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

function __unlink_where_it_does_not_exist__
{
	(( $# != 0 )) || { echo "unlink: missing operand"; return; }
	(( $# > 1 )) && { shift; echo "unlink: extra operand(s) $@"; return; }
	rm "$1"
}
type unlink > /dev/null 2>&1 || alias unlink='__unlink_where_it_does_not_exist__'
