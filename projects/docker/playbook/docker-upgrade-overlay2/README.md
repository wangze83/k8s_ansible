# Docker 升级 Overlay 指南

# 升级步骤

- 进入项目根目录，设置环境变量

```bash
export ANSIBLE_ROOT=`{pwd}`
export ANSIBLE_CONFIG=`{pwd}`/ansible.cfg
```

- 准备访问集群的kubeconfig文件，放到用户 `~/.kube/` 下，例如 `idc` 文件放到 ~/.kube/idc 下。确保可以通过
 
 ``` bash
 kubectl --kubeconfig ~/.kube/idc cluster-info
 ```
 访问到集群。

- 执行升级脚本

进入 `/projects/docker` 目录

```bash
 ansible-playbook -i inventory/hosts playbook/docker-upgrade-overlay2/main.yml -e 'group=XXX'
```

> 说明：升级过程中可能会出现的问题：
> 1. 执行 kubectl drain 无响应，手动处理确保驱逐成功，如果实在无法驱逐，可以强制删除Pod。
> 2. 如果出现逻辑卷无法删除的情况，需要重启机器后重试。
> 3. 如果出现未能识别的磁盘类型，请联系 `wangze` 添加磁盘类型处理脚本。
> 4. 边缘节点暂时不要升级
> 5. 有写机器混布了 glusterfs, 暂时不升级，详见 https://cmdb.wz.se/admin/gluster/brick/
> 6. 专属机器需要逐台升级。避免无资源调度