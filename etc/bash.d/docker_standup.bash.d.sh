#!/usr/bin/env bash

if ! type -P docker &>/dev/null; then
    return 0
fi

function docker_standup() {
    docker build --tag $1 . && docker run -d --name $1 -p $2:$2 $1
    cowsay $1 is built and exposed on $2
}

export -f docker_standup