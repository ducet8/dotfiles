#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function 2cd() {
    if [[ $# == 0 ]]; then
    builtin cd ~ && ll -tr
    elif [[ $@ == '-' ]]; then
    builtin cd - && ll -tr
    elif [[ -d $@ ]]; then
    builtin cd $@ && ll -tr
    else
    echo $@ directory not found!!!
    fi
}

export -f 2cd