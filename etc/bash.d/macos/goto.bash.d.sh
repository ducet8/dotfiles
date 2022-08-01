#!/usr/bin/env bash

function goto() {
   [[ ${Os_Id} == "macos" ]] && tabname $1
   ssh $1
}

export -f goto