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
fi

export BD_OS

bd_debug "BD_OS = ${BD_OS}" 1
