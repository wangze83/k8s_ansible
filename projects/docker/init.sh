#!/bin/bash

ansible-playbook -i inventory/$1 playbook/kernel-upgrade.yaml -e 'group=$1'
sleep 120
ansible-playbook -i inventory/$1 playbook/disk-partition.yaml -e 'group=$1'
ansible-playbook -i inventory/$1 playbook/calico-nosa.yaml -e 'group=$1'
ansible-playbook -i inventory/$1 playbook/main.yml -e 'group=$1'
