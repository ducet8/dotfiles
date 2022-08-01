#!/usr/bin/env bash

function tabreset() {
  echo -n -e "\033]6;1;bg;*;default\a"
}

export -f tabreset