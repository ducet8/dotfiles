#!/usr/bin/env bash

function ssh_setup() {
   cat ~/.ssh/id_rsa.pub | ssh $1 'cat - >> ~/.ssh/authorized_keys'
}

export -f ssh_setup