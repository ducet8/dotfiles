#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function ssh_setup() {
   cat ~/.ssh/id_rsa.pub | ssh ${1} 'cat - >> ~/.ssh/authorized_keys'
}

export -f ssh_setup