#!/bin/bash
yum install -y fuse  fuse-devel pam-devel
cat <<EOF | sudo tee /etc/yum.repos.d/ADDOPS.repo
# ADDOPS.repo
#
# Some description sentence...
#

[ADDOPS-base]
name=ADDOPS-\$releasever - Base
baseurl=http://mirroharbor.wz.cn:8wz//\$releasever/os/\$basearch/
gpgcheck=0

#released updates
[ADDOPS-updates]
name=ADDOPS-\$releasever - Updates
baseurl=http://mirroharbor.wz.cn:8wz//\$releasever/updates/\$basearch/
gpgcheck=0
enabled=0
EOF

mkdir -p /var/lib/lxc/lxcfs/
yum install -y -auto-lxcfs

sed -i "s/containers=.*/containers=\$(\/usr\/bin\/docker ps | grep -v -E 'cattle-prometheus|cattle-system|kube-system|wz-system'| grep k8s_ | grep -v pause | awk '{print \$1}' | grep -v CONTAINE)/"  /usr/local/bin/container_remount_lxcfs.sh

systemctl restart lxcfs.service
systemctl enable lxcfs.service
systemctl status lxcfs.service