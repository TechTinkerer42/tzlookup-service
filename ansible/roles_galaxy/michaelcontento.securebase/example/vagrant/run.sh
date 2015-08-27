#!/usr/bin/env bash -e

function checkCommand {
    command -v "$1" >/dev/null 2>&1 \
        || { echo >&2 "You need to install $1 first!"; exit 1; }
}

if [ ! -d "./roles_galaxy/michaelcontento.securebase" ]; then
    checkCommand ansible-galaxy
    ansible-galaxy install michaelcontento.securebase
fi

checkCommand vagrant
vagrant status | grep "default" | grep "running" > /dev/null
if [ $? -eq 1 ]; then
    vagrant up
fi

checkCommand ansible-playbook-vagrant
ansible-playbook-vagrant "./ansible.yml"
