## 安装

## 补充说明

在 k8s Pod 中没有  使用 lxcfs 时节点安装不会对已有业务造成影响。如果节点安装了 lxcfs ，同时业务 pod 启用了 lxcfs，但是 lxcfs.service  没有启动，会造成业务 pod 在几点上启动失败。此时，需要人工干预：

1. 驱逐节点上使用了 lxcfs 的 pod
2.  移除 `/var/lib/lxcfs/proc/`
3. systemctl start lxcfs.service

## lxcfs 使用

截止到目前（2019-02-21），生产环境集群尚未启动 PodPreset API, 需要人工编辑部署模板，挂载 lxcfs，并且测试发现，不能使用 subPath 挂载。

```yaml
volumeMounts:
  - name: lxcfs-proc-cpuinfo
    mountPath: /proc/cpuinfo
  - name: lxcfs-proc-meminfo
    mountPath: /proc/meminfo
  - name: lxcfs-proc-diskstats
    mountPath: /proc/diskstats
  - name: lxcfs-proc-stat
    mountPath: /proc/stat
  - name: lxcfs-proc-swaps
    mountPath: /proc/swaps
  - name: lxcfs-proc-uptime
    mountPath: /proc/uptime
volumes:
  - name: lxcfs-proc-cpuinfo
    hostPath:
      path: /var/lib/lxcfs/proc/cpuinfo
  - name: lxcfs-proc-diskstats
    hostPath:
      path: /var/lib/lxcfs/proc/diskstats
  - name: lxcfs-proc-meminfo
    hostPath:
      path: /var/lib/lxcfs/proc/meminfo
  - name: lxcfs-proc-stat
    hostPath:
      path: /var/lib/lxcfs/proc/stat
  - name: lxcfs-proc-swaps
    hostPath:
      path: /var/lib/lxcfs/proc/swaps
  - name: lxcfs-proc-uptime
    hostPath:
      path: /var/lib/lxcfs/proc/uptime
```
