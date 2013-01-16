# $Id$
# vim: set autoindent smartindent tabstop=2 shiftwidth=2 expandtab filetype=sh:
TMUX="TERM=screen-256color-bce tmux"
alias tmux="$TMUX attach || $TMUX"
unset TMUX
CVSNT=cvsnt
[[ -n "$(which $CVSNT 2> /dev/null)" ]] || CVSNT=cvs
alias cvsup="$CVSNT -q up -dRP"
export EDITOR=vim
export VISUAL=vim
[[ $UID -eq 0 ]] || alias visudo='sudo -E visudo'

## ----------------------------------------
[ -e "/etc/debian_version" ] || return 
alias debfoster='sudo /usr/bin/debfoster'
alias deborphan='sudo /usr/bin/deborphan'
alias search='apt-cache search'
alias show='apt-cache show'
alias upgrade='apt-get update && apt-get dist-upgrade'
alias ssh-list='for i in /etc/ssh/ssh_host_*.pub; do ssh-keygen -lf $i; done'
if [ $UID -ne 0 ]; then
  alias apt-get='sudo /usr/bin/apt-get'
  alias aptitude='sudo /usr/bin/aptitude'
  alias dpkg-reconfigure='sudo /usr/sbin/dpkg-reconfigure'
  alias visudo='sudo /usr/sbin/visudo'
  alias ifconfig='sudo /sbin/ifconfig'
  alias service='sudo /usr/sbin/service'
  alias htop='sudo /usr/bin/htop'
  alias iptables='sudo /sbin/iptables'
fi
