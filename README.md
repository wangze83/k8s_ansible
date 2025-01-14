Ansible Repo
============

Codebase for Ansible


安装
----

* Set environment variables `ANSIBLE_ROOT` and `ANSIBLE_CONFIG`

* Copy `ansible.cfg.example` to `ansible.cfg`

* Change `remote_user` setting in `ansible.cfg`

* Put ssh key and vault password file in `_keys`


使用
----

    ansible-playbook -i inventory/hosts playbook.yml -e 'group=XXXX'


敏感数据管理
------------

http://docs.ansible.com/ansible/playbooks_vault.html

    ansible-vault encrypt *.vault

    ansible-vault decrypt *.vault
