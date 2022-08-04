#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function tabreset() {
  echo -n -e "\033]6;1;bg;*;default\a"
}

export -f tabreset