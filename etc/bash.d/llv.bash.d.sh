#!/usr/bin/env bash
# Forked from: joseph.tingiris@gmail.com

# ls version sort
function llv() {
    ls -lFha $@ | sort -k 9 -V
}

export -f llv