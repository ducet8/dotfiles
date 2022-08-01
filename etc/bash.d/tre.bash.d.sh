#!/usr/bin/env bash

if ! type -P tree &>/dev/null; then
    return 0
fi

function tre() {
	tree -aC -I '.git' --dirsfirst "$@" | less -FRNX
}

export -f tre