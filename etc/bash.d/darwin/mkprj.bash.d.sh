#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function mkprj() {
    mkdir ${HOME}/projects/${1}
    cp ${HOME}/projects/gitignore ${HOME}/projects/${1}/.gitignore
}

export -f mkprj