#!/usr/bin/env bash

if ! type -P bat &>/dev/null && type -P git &>/dev/null; then
    return 0
fi

function batdiff() {
    git diff --name-only --diff-filter=d | xargs bat --diff
}

export -f batdiff