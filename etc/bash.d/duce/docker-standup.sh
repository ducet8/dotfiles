# 2022.11.09 - ducet8@outlook.com

if ! type -P docker &>/dev/null; then
    return 0
fi

function docker_standup() {
    docker build --tag ${1} . && docker run -d --name ${1} -p ${2}:${2} ${1}
    if ! type -P docker &>/dev/null; then
        cowsay "${1} is built and exposed on ${2}"
    else
        echo "$1 is built and exposed on ${2}"
    fi
}

# export -f docker_standup