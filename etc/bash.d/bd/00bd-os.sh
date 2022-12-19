# Copyright (c) 2022 Joseph Tingiris
# https://github.com/josephtingiris/bash.d/blob/main/LICENSE.md

# TODO: determine os; WIP

BD_OS="unknown"

if type -P uname &> /dev/null; then
    BD_KERNEL_NAME="$(uname -s 2> /dev/null)"

    if [ ${BASH_VERSINFO[0]} -ge 4 ]; then
        BD_KERNEL_NAME=${BD_KERNEL_NAME,,}
    else
        BD_KERNEL_NAME="$(tr [A-Z] [a-z] <<< "${BD_KERNEL_NAME}")"
    fi

    case "${BD_KERNEL_NAME}" in
        bsd*)                       BD_OS="bsd";;
        cygwin*|mingw*|win*)        BD_OS="windows";;
        darwin*)                    BD_OS="darwin";;
        linux*)                     BD_OS="linux";;
        linux*microsoft*)           BD_OS="wsl";;
        solaris*)                   BD_OS="solaris";;
        *)                          BD_OS="unknown:${BD_KERNEL_NAME}"
    esac

    if [ "${BD_OS}" == 'linux' ]; then
        if [ -r /etc/os-release ]; then
            while IFS='=' read -r key value; do 
                if [ "${key}" == 'ID' ]; then 
                    export BD_OS_DISTRIBUTION="${value,,}"
                    bd_debug "BD_OS_DISTRIBUTION = ${BD_OS_DISTRIBUTION}" 1
                fi 
            done < /etc/os-release
            unset -v key value
        elif [ -r /etc/redhat-release ]; then
            export BD_OS_DISTRIBUTION='rhel'
            bd_debug "BD_OS_DISTRIBUTION = ${BD_OS_DISTRIBUTION}" 1
        fi
    fi
fi

export BD_OS

bd_debug "BD_OS = ${BD_OS}" 1
