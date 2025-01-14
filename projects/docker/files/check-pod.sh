#!/bin/bash

function run() {
  host=${1}
  effect=$(kubectl get node $host -o json | jq '.spec.taints[0].effect')
  if [ "$effect" != "" ]; then
    # kubectl taint nodes $host wz.cloud/maintenance=new:NoSchedule-
    kubectl apply -f ./pod/$host-pod.yaml
    sleep 20s
  fi
  podid=$(kubectl get pod check-pod-$host -o json | jq '.status.podIP')
  PODIP=$(echo $podid | sed 's/\"//g')
  ping -c 5 $PODIP >/dev/null
  if [ $? -eq 0 ]; then
    echo $PODIP $(kubectl get node $host -o json | jq '.metadata.name') "ok"
    kubectl delete -f ./pod/$host-pod.yaml
  else
    echo $PODIP $(kubectl get node $host -o json | jq '.metadata.name') "not ok!"
  fi
}

i=1
for host in $(cat $1); do
  if [ $(($i % 10)) -eq 0 ]; then
    sleep 5s
  fi
  i=$(($i + 1))
  run $host &
done
wait
