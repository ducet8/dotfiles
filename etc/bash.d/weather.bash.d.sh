#!/usr/bin/env bash

function weather() {
  #curl "wttr.in/${1: -35209}\?F"
  local location=""
  if [ ! -z $1 ]; then
    location="${1// /+}"
  elif [[ ! -z $WTTR_LOCATION ]]; then
    location=$WTTR_LOCATION
  else
    echo "No location given or set."
    return 1
  fi
  command shift
  local args=""
  for p in $WTTR_PARAMS "$@"; do
    args+=" --data-urlencode $p "
  done
  curl -fGsS -H "Accept-Language: ${LANG%_*}" $args --compressed "wttr.in/${location}"
}

export -f weather