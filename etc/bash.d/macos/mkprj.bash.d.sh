#!/usr/bin/env bash

function mkprj() {
    mkdir /Users/duce/projects/$1
    cp /Users/duce/projects/gitignore /Users/duce/projects/$1/.gitignore
}

export -f mkprj