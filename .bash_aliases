# vim: set autoindent smartindent tabstop=2 shiftwidth=2 expandtab filetype=sh:
alias sb="source ~/.bashrc && cd -"
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
  alias lpg='command dpkg -l|grep -iE'
  alias tfix='reset; stty sane; tput rs1; clear; echo -e "\033c"'
  if type "colordiff" > /dev/null 2>&1; then
    alias diff="command colordiff -u"
  else
    alias diff="command diff -u"
  fi
  for i in debfoster:/usr/bin/debfoster deborphan:/usr/bin/deborphan; do
    __create_abs_alias ${i%%:*} "${i#*:}"
  done
  if [[ $UID -ne 0 ]]; then
    for i in apt-get:/usr/bin/apt-get \
              aptitude:/usr/bin/aptitude \
              apt-mark:/usr/bin/apt-mark \
              apt:/usr/bin/apt \
              dpkg-reconfigure:/usr/sbin/dpkg-reconfigure \
              dpkg:/usr/bin/dpkg \
              service:/usr/sbin/service \
              lsof:/usr/bin/lsof \
              reboot:/usr/sbin/reboot \
              systemctl:/bin/systemctl \
              journalctl:/bin/journalctl
    do
      __create_abs_alias ${i%%:*} "${i#*:}" sudo
    done
  fi
fi
if [[ -e "/etc/redhat-release" ]]; then
  alias search='yum -C search'
  alias show='yum -C info'
  if [[ $UID -ne 0 ]]; then
    for i in ifconfig:/sbin/ifconfig \
              service:/sbin/service \
              lsof:/usr/sbin/lsof \
              reboot:/sbin/reboot \
              yum:/usr/bin/yum \
              iptables:/sbin/iptables
    do
      __create_abs_alias ${i%%:*} "${i#*:}" sudo
    done
    alias upgrade='sudo yum update'
  else
    alias upgrade='yum update'
  fi
fi
if type "pacman" > /dev/null 2>&1; then
  if [[ $UID -ne 0 ]]; then
    alias upgrade='sudo pacman -Syu'
  else
    alias upgrade='pacman -Syu'
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
