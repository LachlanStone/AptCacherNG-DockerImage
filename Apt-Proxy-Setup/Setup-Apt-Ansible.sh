#!/bin/bash
ansible-playbook -T 30 -b --ask-become-pass --ask-pass Setup-Apt-Ansible.yml

