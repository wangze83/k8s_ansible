#!/bin/bash

name=`echo $1 | awk -F"." '{print $1}' `

echo "apiVersion: v1
kind: Pod
metadata:"
echo "  name: check-pod-$1"
echo "spec:"
echo "  affinity:"
echo "    nodeAffinity:"
echo "      requiredDuringSchedulingIgnoredDuringExecution:"
echo "        nodeSelectorTerms:"
echo "        - matchExpressions:"
echo "          - key: kubernetes.io/hostname"
echo "            operator: In"
echo "            values:"
echo "            - $1 "
echo "  containers:"
echo "  - name: check-pod"
echo "    image: harbor.wz.net/infra/busybox:latest"
echo "    command:"
echo "      - sleep"
echo "      - \"wz0\""
echo "  restartPolicy: Always"
echo "  tolerations:"
echo "  - key: \"wz.cloud/maintenance\""
echo "    operator: \"Equal\""
echo "    value: \"new\""
echo "    effect: \"NoSchedule\""
