# vim: set autoindent smartindent tabstop=2 shiftwidth=2 expandtab filetype=sh:
alias sb="source ~/.bashrc"
type sort > /dev/null 2>&1 && { alias e="env|sort -i"; } || { alias e="env"; }
if [[ -n "$(which vim 2> /dev/null)" ]]; then
  export EDITOR=$(which vim)
  export VISUAL=$(which vim)
fi
[[ $UID -eq 0 ]] || alias visudo='sudo -E visudo'

# Syntax: __create_abs_alias <name> <command>
function __create_abs_alias
{
  file "$2" > /dev/null 2>&1 || return
  type "$2" > /dev/null 2>&1 || return
  [[ -n "$3" ]] && { alias $1="$3 $2"; } || { alias $1="$2"; }
}

## ----------------------------------------
if [[ -e "/etc/debian_version" ]]; then
  alias ssh-list='for i in /etc/ssh/ssh_host_*.pub; do test -r $i && ssh-keygen -lf $i; done; for i in /etc/ssh/ssh_host_*.pub; do test -r $i && ssh-keygen -r $(hostname -s) -f $i; done'
  alias search='apt-cache search'
  alias show='apt-cache show'
  alias upgrade='apt-get update && apt-get dist-upgrade'
  alias apti='apt-get --no-install-recommends install'
  alias purge='apt-get --purge remove'
  alias autopurge='apt-get --purge autoremove'
  alias lp='command dpkg -l'
  alias lpi='command dpkg -l|grep ^ii'
  alias lpg='command dpkg -l|grep -iE'
  if type "istat" > /dev/null 2>&1; then
    alias wistat='watch -n 10 "istat|cut -c 1-\$(tput cols)"'
  fi
  if type "colordiff" > /dev/null 2>&1; then
    alias diff="command colordiff -u"
    if type "svn" > /dev/null 2>&1; then
      alias svndiff="command svn diff --diff-cmd colordiff"
    else
      alias svndiff="command svn diff"
    fi
  else
    alias diff="command diff -u"
  fi
  for i in debfoster:/usr/bin/debfoster deborphan:/usr/bin/deborphan; do
    __create_abs_alias ${i%%:*} "${i#*:}"
  done
  if [[ $UID -ne 0 ]]; then
    for i in apt-get:/usr/bin/apt-get \
              aptitude:/usr/bin/aptitude \
              dpkg-reconfigure:/usr/sbin/dpkg-reconfigure \
              ifconfig:/sbin/ifconfig \
              service:/usr/sbin/service \
              htop:/usr/bin/htop \
              lsof:/usr/bin/lsof \
              reboot:/usr/sbin/reboot \
              iptables:/sbin/iptables \
              iptables-save:/sbin/iptables-save \
              iptables-restore:/sbin/iptables-restore \
              ip6tables:/sbin/ip6tables \
              ip6tables-save:/sbin/ip6tables-save \
              ip6tables-restore:/sbin/ip6tables-restore \
              ipset:/sbin/ipset \
              iptraf-ng:/usr/sbin/iptraf-ng \
              tcpdump:/usr/sbin/tcpdump \
              netsniff-ng:/usr/sbin/netsniff-ng \
              firewall:/sbin/firewall \
              apt-file:/usr/bin/apt-file
    do
      __create_abs_alias ${i%%:*} "${i#*:}" sudo
    done
    alias chorme="sudo /bin/chown -hR $(whoami):"
  else
    alias chorme="chown -hR $(whoami):"
  fi
fi
if [[ -e "/etc/redhat-release" ]]; then
  alias search='yum -C search'
  alias show='yum -C info'
  if [[ $UID -ne 0 ]]; then
    for i in ifconfig:/sbin/ifconfig \
              service:/sbin/service \
              htop:/usr/bin/htop \
              lsof:/usr/sbin/lsof \
              reboot:/sbin/reboot \
              tcpdump:/usr/sbin/tcpdump \
              yum:/usr/bin/yum \
              iptables:/sbin/iptables
    do
      __create_abs_alias ${i%%:*} "${i#*:}" sudo
    done
    alias chorme="sudo /bin/chown -hR $(whoami):"
    alias upgrade='sudo yum update'
  else
    alias chorme="chown -hR $(whoami):"
    alias upgrade='yum update'
  fi
fi
if [[ $(uname -s) == "FreeBSD" ]] && type pkg > /dev/null 2>&1; then
  alias search='pkg search'
  alias show='pkg info'
  if [[ $UID -ne 0 ]]; then
    for i in pkg:/usr/sbin/pkg
    do
      __create_abs_alias ${i%%:*} "${i#*:}" sudo
    done
    alias upgrade='sudo pkg update && sudo pkg upgrade'
  else
    alias upgrade='pkg update && pkg upgrade'
  fi
fi
unset __create_abs_alias
unset i

# http://unix.stackexchange.com/a/4220
# function make_completion_wrapper () {
# 	local function_name="$2"
# 	local arg_count=$(($#-3))
# 	local comp_function_name="$1"
# 	shift 2
# 	local function="
# 		function $function_name {
# 			((COMP_CWORD+=$arg_count))
# 			COMP_WORDS=( "$@" \${COMP_WORDS[@]:1} )
# 			"$comp_function_name"
# 			return 0
# 		}"
# 	eval "$function"
# }

# make_completion_wrapper _apt_get    _apt_get_apti    apt-get --no-install-recommends install
# make_completion_wrapper _apt_get   _apt_get_setup    apt-get install
# make_completion_wrapper _apt_get   _apt_get_purge    apt-get --purge remove
# make_completion_wrapper _apt_cache _apt_cache_search apt-cache search
# make_completion_wrapper _apt_cache _apt_cache_show   apt-cache show
# complete -F _apt_get_apti  apti
# complete -F _apt_get_setup setup
# complete -F _apt_get_purge purge
# complete -F _apt_cache_search search
# complete -F _apt_cache_show show
# unset make_completion_wrapper
