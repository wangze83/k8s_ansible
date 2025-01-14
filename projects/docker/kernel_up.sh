#!/bin/bash
echo $1
echo $2
ansible-playbook -i //ansible/projects/docker/inventory/$1 //ansible/projects/docker/playbook/kernel-upgrade.yaml -e 'group=$2'
