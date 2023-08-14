# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if ! type -P docker &>/dev/null; then
    return 0
fi

docker_destroy() {
    container=`docker ps | grep ${1} | awk '{print $1}'`
    docker stop ${container}
    docker rm ${container}
    if ! type -P docker &>/dev/null; then
        cowsay "${container} is stopped and removed"
    else
        echo "${container} is stopped and removed"
    fi
}
