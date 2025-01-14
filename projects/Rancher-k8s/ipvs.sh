if [ `cat /etc/selinux/config |grep -vE '^#|^$'|grep "SELINUX=disabled$"|wc -l` -ne 1 ] ;then sed -i '/SELINUX=/d' /etc/selinux/config;echo "SELINUX=disabled" >>/etc/selinux/config;fi
if [ `cat /etc/selinux/config |grep -vE '^#|^$'|grep "SELINUXTYPE=targeted$"|wc -l` -ne 1 ] ;then sed -i '/SELINUXTYPE=/d' /etc/selinux/config;echo "SELINUXTYPE=targeted" >>/etc/selinux/config;fi

systemctl stop firewalld
systemctl disable firewalld

modprobe br_netfilter
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sysctl -p

yum install -y ipvsadm ipset >/dev/null

cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
ipvs_modules="ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_sh ip_vs_fo ip_vs_nq ip_vs_sed ip_vs_ftp nf_conntrack_ipv4"
for kernel_module in \${ipvs_modules}; do
    /sbin/modinfo -F filename \${kernel_module} > /dev/null 2>&1
    if [ \$? -eq 0 ]; then
        /sbin/modprobe \${kernel_module}
    fi
done
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep ip_vs

