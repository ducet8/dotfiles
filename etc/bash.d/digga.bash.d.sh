#!/usr/bin/env bash

if ! type -P dig &>/dev/null; then
    return 0
fi

function digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

export -f digga