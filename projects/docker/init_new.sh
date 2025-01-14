#!/bin/bash
ansible-playbook -i //ansible/projects/docker/inventory/$1 //ansible/projects/docker/playbook/disk-partition.yaml -e 'group=$2'
ansible-playbook -i //ansible/projects/docker/inventory/$1 //ansible/projects/docker/playbook/calico-nosa.yaml -e 'group=$2'
ansible-playbook -i //ansible/projects/docker/inventory/$1 //ansible/projects/docker/playbook/main.yml -e 'group=$2'
