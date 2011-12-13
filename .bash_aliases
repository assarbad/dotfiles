# $Date$ - $Id$
[ -e "/etc/debian_version" ] || return 

alias debfoster='sudo /usr/bin/debfoster'
alias deborphan='sudo /usr/bin/deborphan'
alias search='apt-cache search'
alias show='apt-cache show'
alias upgrade='apt-get update && apt-get dist-upgrade'
alias ssh-list='for i in /etc/ssh/ssh_host_*.pub; do ssh-keygen -lf $i; done'
if [ $UID -ne 0 ]; then
	alias apt-get='sudo /usr/bin/apt-get'
	alias dpkg-reconfigure='sudo /usr/sbin/dpkg-reconfigure'
	alias visudo='sudo /usr/sbin/visudo'
	alias ifconfig='sudo /sbin/ifconfig'
	alias service='sudo /usr/sbin/service'
	alias htop='sudo /usr/bin/htop'
	alias iptables='sudo /sbin/iptables'
fi
