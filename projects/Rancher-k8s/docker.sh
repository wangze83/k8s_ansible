systemctl stop docker
# 在各个机器上安装docker
yum remove -y  docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine \
            docker-ce 
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo 
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
yum makecache

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# 指定版本19.03.14
yum install -y docker-ce-19.03.14-3.el7 docker-ce-cli-19.03.14-3.el7 containerd.io-1.3.9-3.1.el7
systemctl enable docker

mkdir -p /etc/docker/ && touch /etc/docker/daemon.json
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": ["https://8dexs4ag.mirror.aliyuncs.com"],
  "storage-driver": "overlay2",
  "oom-score-adjust": -1000,
  "storage-opts": [
      "overlay2.override_kernel_check=true",
      "overlay2.size=50G"
    ],
  "log-opts": {
    "max-size": "4g",
    "max-file": "5"
    },
  "live-restore": true,
  "selinux-enabled": false,
  "init": true
}
EOF

systemctl daemon-reload
systemctl restart docker 

#关闭swap
swapoff -a 
sed -i 's/.*swap.*/#&/' /etc/fstab

#安装keyutils为了mount cephfs
yum install -y keyutils
#keyctl clear $((16#$(sudo cat /proc/keys | grep .dns_resolver | awk '{print $1;}')))
yum -y install lldpd && systemctl start lldpd
