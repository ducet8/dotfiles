#!/usr/bin/env bash

# ls version sort
function llv() {
    ls -lFha $@ | sort -k 9 -V
}

export -f llv