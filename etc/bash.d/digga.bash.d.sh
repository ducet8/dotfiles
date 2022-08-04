#!/usr/bin/env bash
# Forked from: Jess Frizelle
# 2022.08.04 - ducet8@outlook.com

if ! type -P dig &>/dev/null; then
    return 0
fi

function digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

export -f digga