#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function tabname() {
   printf "\e]1;$1\a"
}

export -f tabname