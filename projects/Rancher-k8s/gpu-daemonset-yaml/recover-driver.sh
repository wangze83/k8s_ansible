#!/bin/bash
if [ $# -ne 1 ];then
    echo "Usage: recover-driver DRIVER_POD_NAME"
    exit 1
fi
kubectl get pods -n gpu-operator-resources $1 >/dev/null 2>&1
if [ $? -ne 0 ];then
    echo "$1 don't exist"
    exit 1
fi

# 1. Get all resource's name
node=`kubectl get pods -n gpu-operator-resources $1 -o wide | grep -v NAME | awk '{print $7}'`
node_role=`kubectl get nodes $node --show-labels | grep wz.cloud/vgpu >/dev/null 2>&1;if [ $? -ne 0 ];then echo "None";else echo $node;fi`
dcgm_name=`kubectl get pods -l app.kubernetes.io/name=dcgm-exporter -n gpu-operator-resources --field-selector spec.nodeName=$node 2>/dev/null | grep -v "NAME" | awk '{print $1}';if [ $? -ne 0 ];then echo "";fi`
toolkit_name=`kubectl get pods -l app=nvidia-container-toolkit-daemonset -n gpu-operator-resources --field-selector spec.nodeName=$node 2>/dev/null | grep -v "NAME" | awk '{print $1}';if [ $? -ne 0 ];then echo "";fi`
device_plugin_name=`kubectl get pods -l app=nvidia-device-plugin-daemonset -n gpu-operator-resources --field-selector spec.nodeName=$node 2>/dev/null | grep -v "NAME" | awk '{print $1}';if [ $? -ne 0 ];then echo "";fi`
driver_name=`kubectl get pods -l app=nvidia-driver-daemonset -n gpu-operator-resources --field-selector spec.nodeName=$node 2>/dev/null | grep -v "NAME" | awk '{print $1}';if [ $? -ne 0 ];then echo "";fi`

if [ $node_role != "None" ];then
    gpushare_name=`kubectl get pods -l name=gpushare-device-plugin-ds -n kube-system --field-selector spec.nodeName=$node 2>/dev/null | grep -v "NAME" | awk '{print $1}';if [ $? -ne 0 ];then echo "";fi`
    evict_name=`kubectl get pods -l name=device-plugin-evict-ds -n kube-system --field-selector spec.nodeName=$node 2>/dev/null | grep -v "NAME" | awk '{print $1}';if [ $? -ne 0 ];then echo "";fi`
fi


# 2. Delete all pod in specific order
timeout 600 kubectl drain $node --delete-local-data=true --ignore-daemonsets=true --force >/dev/null 2>&1
if [ $? -eq 124 ];then
    echo "驱逐节点$node超时，错误退出"
fi

if [ $node_role != "None" ];then
    echo 'Aptx6zsm!@#' | sshpass -p 'Aptx6zsm!@#' ssh -tt -o StrictHostKeyChecking=no zhangsiming@$node -- sudo systemctl stop amp-host-agent.service
    kubectl delete pods -n kube-system $gpushare_name $evict_name --force --grace-period=0 >/dev/null 2>&1
fi
kubectl delete pods -n gpu-operator-resources $dcgm_name $toolkit_name $device_plugin_name --force --grace-period=0 >/dev/null 2>&1

sleep 3
kubectl delete pods -n gpu-operator-resources $driver_name --force --grace-period=0 >/dev/null 2>&1

# 3. Check the result
sleep 5

status=`kubectl get pods -l app=nvidia-driver-daemonset -n gpu-operator-resources --field-selector spec.nodeName=$node | grep -v "NAME" | awk '{print $3}'`
if [ $status == "Running" ];then
    echo "$node 成功修复"
    if [ $node_role != "None" ];then
        echo 'Aptx6zsm!@#' | sshpass -p 'Aptx6zsm!@#' ssh -tt -o StrictHostKeyChecking=no zhangsiming@$node -- sudo systemctl restart amp-host-agent.service
    fi
    kubectl uncordon $node >/dev/null 2>&1
    echo "修复结果如下:"
    kubectl get nodes $node
    kubectl get pods -A -o wide | grep "$node" | egrep "nvidia|device-plugin|dcgm-exporter"
    if [ $node_role != "None" ];then
        sshpass -p 'Aptx6zsm!@#' ssh -tt -o StrictHostKeyChecking=no zhangsiming@$node -- systemctl status amp-host-agent.service
    fi
else
    echo "$node 修复失败"
    kubectl uncordon $node >/dev/null 2>&1
    echo "修复结果如下:"
    kubectl get nodes $node
    kubectl get pods -A -o wide | grep "$node" | egrep "nvidia|device-plugin|dcgm-exporter"
    if [ $node_role != "None" ];then
        sshpass -p 'Aptx6zsm!@#' ssh -tt -o StrictHostKeyChecking=no zhangsiming@$node -- systemctl status amp-host-agent.service
    fi
fi
