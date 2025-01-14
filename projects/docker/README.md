# 安装准备

- 其他部门请按需申请

----

**group名字必须严格按照原有的规则 否则会获取不到变量**

# 安装步骤

## 进入项目根目录，设置环境变量

```bash
export ANSIBLE_ROOT=`{pwd}` && export ANSIBLE_CONFIG=`{pwd}`/ansible.cfg
```

----

## 安装Master节点

----

### 安装规划

集群中的机器可以分为几种：
- master： 一般3台独占机器
- etcd: 一般也是3台，或者5台，7台，可以与master混合部署，需要ssd
- node：工作节点，按需增加

安装之前，需要申请好机器，并申请calico网段

----

### 创建集群配置

在inventory/group_vars创建一份集群的配置文件

主要关注几个字段：

```
# Calico
calico_idc: idc2
calico_home: /data/usr/calico
calico_pool:
    name: idc2-19-0
    cidr: xxxx
calico_as: 65098
calicoctl:
    etcd_endpoints: https://xxxx:2379,https://xxxx:2379,https://xxxx:2379
    etcd_key: 
    etcd_cert:
    etcd_ca:
```

- calico_pool: 需要预先向netops申请
- etcd_endpoints: etcd集群地址

```
etcd_config:
    data-dir: /data/var/lib/etcd/etcd-2379
    peer-port: 2380
    client-port: 2379
    token: etcd-idc2
    cluster: "en24.safe.idc2.wz.net=https://xxxx:2380,\
              en25.safe.idc2.wz.net=https://xxxx:2380,\
              en26.safe.idc2.wz.net=https://xxxx:2380"
```
- cluster: 规划的etcd机器列表

```
# Kubernetes
rbac: false
kube_home: /data/usr/kubernetes
kube_user: root
kube_group: root
idc: idc2
orgs: group
```
- kube_user: kubectl等工具所属的用户和组
- orgs: 所属业务

```
kube_cluster_name: kube-idc2
kube_etcd_servers: https://xxxx:2379,https://xxxx:2379,https://xxxx:2379
kube_api_servers: https://xxxx
kube_service_ip_range: xxxx/16
kube_dns_replicas: 2
kube_dns_domain: wz.local
kube_dns_server_ip: xxxx
```
- kube_api_servers: apiserver访问地址，通常配置为一个VIP地址，需预先申请
- kube_dns_domain: 内部svc地址所属的domain，要避免和内部网址冲突

----

### 生成证书


#### ca证书

修改ca-csr.json

```
{
  "CN": "X wz SOFTWARE CO. LIMITED",
  "key": {
    "algo": "ecdsa",
    "size": 384
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "X wz",
      "OU": "Search"
    }
  ]
}
```
一般只需要修改OU字段

执行./gen_ca.sh即生成ca证书，然后将证书拷贝到 projects/docker/files/certs/[OU]下

#### 生成master节点证书

如需修改所属部门信息，可以修改gen_csr.sh里的OU字段。

执行./gen_master_cert.sh [host] [vip]

生成[host].pem、[host]-key.pem、[host].csr，移动到projects/docker/files/node-certs/docker_certs下

#### 生成node节点证书

如需修改所属部门信息，可以修改gen_csr.sh里的OU字段。

执行./gen_node_cert.sh [host]

生成[host].pem、[host]-key.pem、[host].csr，移动到projects/docker/files/node-certs/docker_certs下

#### 生成kube-service-account证书

如需修改所属部门信息，可以修改kube-service-account.json里的OU字段。

执行./gen_kube-service-account.sh

生成的kube-service-account.pem和kube-service-account-key.pem拷贝到projects/docker/files/certs/[OU]下

----

### 配置Hosts

修改inventory/hosts，配置master地址

```
en24.safe.idc2 master=true
en25.safe.idc2 master=true
en26.safe.idc2 master=true
```

----

### 升级内核，重启

```bash
 ansible-playbook -i inventory/hosts playbook/kernel-upgrade.yaml -e 'group=XXX'
```

----

### 磁盘分区

```bash
 ansible-playbook -i inventory/hosts playbook/disk-partition.yaml -e 'group=XXX'
```

> 根据磁盘类型自动分区，如果您的磁盘类型无法匹配已经存在的磁盘类型，请参考 storage-overlayfs 建立新的磁盘分区文件

----

### 安装etcd

首次安装，需要先安装etcd

```bash
 ansible-playbook -i inventory/hosts playbook/etcd.yml -e 'group=XXX'
```

----

### 初始化calico

```bash
 ansible-playbook -i inventory/hosts playbook/calico-init.yaml -e 'group=XXX'
```

发送邮件到 netops 初始化网络配置。
调用 netops 接口初始化在交换机侧初始化网络配置(失败率可能很高，重复执行即可）

```bash
 ansible-playbook -i inventory/hosts playbook/calico-nosa.yaml -e 'group=XXX'
```
----

### 安装节点

```bash
 ansible-playbook -i inventory/hosts playbook/main.yml -e 'group=XXX'
```

----

### 安装addons

#### 安装dns

拷贝hacks/addons目录到任意一台master，sudo到配置的{{kube_user}}

先修改~/.bashrc
```
PATH=$PATH:/data/usr/kubernetes/kubernetes/bin

```

进入coredns目录
```
kubectl apply -f .
```

再执行
```
kubectl apply -f wz.cloud-secret.yaml
```

----

## 安装工作节点

> 旧机器重装只需要执行这个步骤，其中 `初始化calico` 的步骤中不需要执行netops脚本。

### 检查 ip

到 `inventory/group_vars` 查看机器 ip 是否在 ip 段内。

----

### 准备证书

到 `https://cmdb.wz.cloud` 申请证书，然后下载到本地。修改 `/projects/docker/playbook/certs.yml`
下配置的证书路径为本地证书存放路径


注意脚本会报错 因为要制定安全集群的证书目录

----

###  升级内核，重启

```bash
 ansible-playbook -i inventory/hosts playbook/kernel-upgrade.yaml -e 'group=XXX'
```

----

## 格盘 跟master节点一样

###  初始化calico

```bash
 ansible-playbook -i inventory/hosts playbook/calico-init.yaml -e 'group=XXX'
```

发送邮件到 netops 初始化网络配置。记得服务端要开启lldp

注意新的netops接口 返回了一个as number 现在这个新的number需要填充进templates/peer.sh.j2

调用 netops 接口初始化在交换机侧初始化网络配置(失败率可能很高，重复执行即可）

```bash
 ansible-playbook -i inventory/hosts playbook/calico-nosa.yaml -e 'group=XXX'
```

----

###  安装节点

```bash
 ansible-playbook -i inventory/hosts playbook/main.yml -e 'group=XXX'
```
