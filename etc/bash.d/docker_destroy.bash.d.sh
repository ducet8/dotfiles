#!/usr/bin/env bash

if ! type -P docker &>/dev/null; then
    return 0
fi

function docker_destroy() {
    container=`docker ps | grep $1 | awk '{print $1}'`
    docker stop $container
    docker rm $container
    cowsay $container is stopped and removed
}

export -f docker_destroy