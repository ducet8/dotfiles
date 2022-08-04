#!/usr/bin/env bash

# TODO: Add ability to accept options
function goto() {
   [[ ${Os_Id,,} == "darwin" ]] && tabname $1
   ssh $1
}

export -f goto