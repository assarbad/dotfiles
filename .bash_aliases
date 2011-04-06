[ -e "/etc/debian_version" ] || return 

alias debfoster='sudo /usr/bin/debfoster'
alias deborphan='sudo /usr/bin/deborphan'
alias search='apt-cache search'
alias show='apt-cache show'
alias upgrade='apt-get update && apt-get dist-upgrade'
if [ $UID -eq 0 ]; then
	alias beroot='echo You are root already, silly!'
else
	alias apt-get='sudo /usr/bin/apt-get'
	alias dpkg-reconfigure='sudo /usr/sbin/dpkg-reconfigure'
	alias visudo='sudo /usr/sbin/visudo'
	alias ifconfig='sudo /sbin/ifconfig'
	alias beroot='sudo su -'
	alias virsh='sudo /usr/bin/virsh'
	alias virt-top='sudo /usr/bin/virt-top'
	alias service='sudo /usr/sbin/service'
	alias htop='sudo /usr/bin/htop'
	alias iptables='sudo /sbin/iptables'
fi
