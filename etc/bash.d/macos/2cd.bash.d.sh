#!/usr/bin/env bash

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