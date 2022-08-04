#!/usr/bin/env bash

function tabname() {
   printf "\e]1;$1\a"
}

export -f tabname