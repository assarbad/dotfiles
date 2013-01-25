# $Id$
# vim: set autoindent smartindent tabstop=2 shiftwidth=2 expandtab filetype=sh:
TMUX="TERM=screen-256color-bce tmux"
alias mux="$TMUX attach-session -d -t $(hostname -s) || $TMUX new-session -s $(hostname -s) -n shell"
unset TMUX
CVSNT=cvsnt
[[ -n "$(which $CVSNT 2> /dev/null)" ]] || CVSNT=cvs
alias cvsup="$CVSNT -q up -dRP"
alias refresh-bashrc="source ~/.bashrc"
if [[ -n "$(which vim 2> /dev/null)" ]]; then
  export EDITOR=$(which vim)
  export VISUAL=$(which vim)
fi
[[ $UID -eq 0 ]] || alias visudo='sudo -E visudo'

## ----------------------------------------
if [[ -e "/etc/debian_version" ]]; then
  alias debfoster='sudo /usr/bin/debfoster'
  alias deborphan='sudo /usr/bin/deborphan'
  alias search='apt-cache search'
  alias show='apt-cache show'
  alias upgrade='apt-get update && apt-get dist-upgrade'
  alias ssh-list='for i in /etc/ssh/ssh_host_*.pub; do ssh-keygen -lf $i; done'
  alias chorme="sudo /bin/chown -hR $(whoami):"
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
fi
