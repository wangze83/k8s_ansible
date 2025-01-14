#!/bin/bash

file_suffix=$(date -u +"%Y-%m-%d-%H")
etcd_backup_path="/data/var/lib/etcd/snapshot.db.${file_suffix}"

hostname=$(hostname)
ip=$(dig +short $hostname)

cert_path="/data/usr/certs/"
cacert="${cert_path}/ca.pem"
cert="${cert_path}/${hostname}.pem"
certkey="${cert_path}/${hostname}-key.pem"

etcdctl=/data/usr/etcd/etcd/etcdctl
etcd_endpoints="https://${ip}:2379"

sh -c "ETCDCTL_API=3 ${etcdctl} --cacert=${cacert} --cert=${cert} --key=${certkey} --endpoints=${etcd_endpoints} snapshot save ${etcd_backup_path}"