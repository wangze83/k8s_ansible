#!/bin/bash
echo '################### [ pantheon deploy ] ####################'
sed -i '/SV:123456/d' /etc/inittab
wget -P /tmp/ bjdt.wz.net:8wz/daemontools
sleep 2
cp /tmp/daemontools /etc/init.d/
chmod +x /etc/init.d/daemontools
chkconfig --add daemontools
chkconfig daemontools --level 2345 on
nohup /etc/init.d/daemontools start

user=$(id -un)
sys=$(uname -p)
os=$(uname -s)

echo "user:$user sys:$sys os:$os"
[ $user != "root" -o $os != 'Linux' -o $sys != 'x86_64' ] && exit 1

#sysver=$(awk '{print $3}' /etc/redhat-release)
sysver='7.1'
echo "system verison: $sysver"

WEB='http://bjdt.wz.net:8wz'
DIR='deploy'
PERLPKG4C='perl-5.14.2_CentOS.el6.tar.gz'

if [ "$sysver" = '5.4' ];then
    echo "5.4";
    TCPServer='wz-TCPServer-0.88-130702005.el5.x86_64.rpm'
elif [ "$sysver" = '6.2' ];then
    echo "6.2";
    TCPServer='wz-TCPServer-0.88-130702005.el6.x86_64.rpm'
elif [ "$sysver" = '6.6' -o "$sysver" = '7.1' ];then
    echo "6.6";
    TCPServer='wz-TCPServer-0.88-130702005.el6.x86_64.rpm'
else
    echo "unkown OS"; exit 1;
fi

if [ -f "/s/ops/pantheon/tools/.pantheon_update_lock" ];then
    echo ".pantheon_update_lock"
    exit 1;
fi

wget $WEB/p/$DIR/$PERLPKG4C -O /tmp/$PERLPKG4C 2>/dev/null &&
tar zxf /tmp/$PERLPKG4C -C / &&
wget $WEB/p/.config -O /s/ops/pantheon/tools/.config &&
wget $WEB/p/deploy/$TCPServer -O /tmp/$TCPServer &&
rpm -ivh /tmp/$TCPServer &&
chmod a+r /s/ops/pantheon/tools/.config && echo OK

export PATH=$PATH:/usr/local/bin
/s/ops/pantheon/tools/daemon -k poros.proxy
killall tcpserver
killall tcpserver
sleep 2
/s/ops/pantheon/tools/daemon --r poros.proxy
