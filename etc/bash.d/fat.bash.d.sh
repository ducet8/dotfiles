#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

# Read exported functions and pipe them through bat, if available
function fat() {
    if type -P bat &>/dev/null; then
        typeset -f ${1} | bat -l sh
    else
        typeset -f ${1}
    fi
}

export -f fat