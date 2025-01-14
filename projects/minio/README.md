## 安装

### 1. 集群规划

#### 模式与安全

- 使用 Minio Distributed 模式，可以防止数据**位衰减（bit rot）**

- **4 个**集群节点每个节点挂载 **2 个** 2000GibB 容量的 ceph rbd 设备

- 能在 $N/2$ 既 **2 节点损坏**的情况下保证**数据安全**并服务降级到**只读模式**

- 能在 $N/2+1$ 既 **1 节点损坏**的情况下保证数据安全并继续提供**读写服务**

#### 磁盘使用率

纠删码把数据拆分成 $n$ 个数据分片和 $m$ 个奇偶校验块。

Minio 默认的 Storage Class 纠删码配置为 $n= N/2$ , $m=N/2$。

$磁盘利用率 = n/(n+m)=(N/2)/(N/2+N/2)=0.5$。

### 2. 安装

#### 准备 rbd

- 创建 4 个 1000GiB 的 ceph rbd image
- 格式化 rbd image 文件系统为 xfs

#### 配置 ansbile 脚本

- 在 ./projects/minio/inventory/host_vars 中创建机器变量文件，设置该节点使用的 rbd image 名称与 map 后的设备路径。
- 在 ./projects/minio/inventory/hosts 增加需要安装的分组和节点

#### 执行安装

```bash
# 替换 CLUSTER 和 YOUR_USERNAME
cd ./projects/minio/ && ansible-playbook -i inventory/hosts playbook/install_minio_idc.yaml -e "group=CLUSTER" -k -u YOUR_USERNAME -K
```
