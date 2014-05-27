# $Id$
# vim: set autoindent smartindent tabstop=2 shiftwidth=2 expandtab filetype=sh:
alias sb="source ~/.bashrc"
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
  alias ssh-list='for i in /etc/ssh/ssh_host_*.pub; do ssh-keygen -lf $i; done; for i in /etc/ssh/ssh_host_*.pub; do ssh-keygen -r $(hostname -s) -f $i; done'
  alias search='apt-cache search'
  alias show='apt-cache show'
  alias upgrade='apt-get update && apt-get dist-upgrade'
  alias apti='apt-get --no-install-recommends install'
  alias setup='apt-get install'
  alias purge='apt-get purge'
  alias lp='command dpkg -l'
  alias lpi='command dpkg -l|grep ^ii'
  alias lpg='command dpkg -l|grep -iE'
  if type "istat" > /dev/null 2>&1; then
    alias wistat='watch -n 10 "istat|cut -c 1-$(tput cols)"'
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
              iptables:/sbin/iptables \
              iptables-save:/sbin/iptables-save \
              iptables-restore:/sbin/iptables-restore \
              ip6tables:/sbin/ip6tables \
              ip6tables-save:/sbin/ip6tables-save \
              ip6tables-restore:/sbin/ip6tables-restore \
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
unset __create_abs_alias
