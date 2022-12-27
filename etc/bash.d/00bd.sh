# Copyright (c) 2022 Joseph Tingiris
# https://github.com/bash-d/bd/blob/main/LICENSE.md

# 00bd.sh: an autoloader for bash shell source

# https://github.com/bash-d/bd/blob/main/README.md

#
# metadata
#

# bash.d: exports BD_DEBUG BD_ID BD_HOME BD_OS BD_USER BD_VERSION
# vim: ft=sh:ts=4:sw=4

#
# init
#

# prevent non-bash shells (for now)
[ "${BASH_SOURCE}" == "" ] && return &> /dev/null

# prevent non-sourced execution (for now; function bd_status(), etc. later ...)
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (instead, 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

# handle upgrade argument
if [ "${1}" == "upgrade" ]; then
    BD_UPDATE_URL="https://raw.githubusercontent.com/bash-d/bd/main/00bd.sh"

    bd_debug "${BASH_SOURCE} upgrade" 1

    bd_upgrade

    return $?
fi

# verify SHELL (why?)
SHELL="${SHELL:-$(command -v sh 2> /dev/null)}"
[ ! -x "${SHELL}" ] && return 1

#
# globals
#

export BD_VERSION=0.38

BD_CONF_FILE=".bash.d.conf"
BD_SUB_DIR="etc/bash.d"

export BD_DEBUG=${BD_DEBUG:-0} # level >0 enables debugging

#
# functions
#

# stub bd_ansi (for bd_debug)
function bd_ansi() {
    return
}

# set bd aliases
function bd_aliases() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    [ -f "${BD_HOME}/.bashrc" ] && alias bd="source '${BD_HOME}/.bashrc'" || alias bd="source '${BD_HOME}/.bash_profile'"
}

# add a specific subdirectory via bd_bagger; a single 'bag' is simply a subdirectory in ${BD_PATH}
function bd_bag() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_bag_name="$1"

    local bag_dir bag_dirs

    bag_dirs=()

    bag_dirs+=("/${BD_SUB_DIR}/${bd_bag_name}")

    [ "${BD_HOME}" != "${HOME}" ] && bag_dirs+=("${BD_HOME}/${BD_SUB_DIR}/${bd_bag_name}")
    [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ] && bag_dirs+=("${HOME}/${BD_SUB_DIR}/${bd_bag_name}")

    for bag_dir in ${bag_dirs[@]}; do
        bag_dir=${bag_dir//\/\//\/}
        bd_debug "1 bag_dir = ${bag_dir} [bag]" 4

        bag_dir="$(bd_realpath "${bag_dir}")"
        bd_debug "2 bag_dir = ${bag_dir} [bag]" 4

        bd_bagger "${bag_dir}"
    done

    unset -v bag_dir
}

# add unique, existing directories to the global BD_BAG_DIRS array (& preserve the natural order)
function bd_bagger() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_bagger_dir="${1//\/\//\/}"

    bd_debug "1 bd_bagger_dir = ${bd_bagger_dir}" 4

    [ ${#bd_bagger_dir} -eq 0 ] && return 1

    [ ! -d "${bd_bagger_dir}" ] && return 1

    bd_bagger_dir="$(bd_realpath "${bd_bagger_dir}")"
    bd_debug "2 bd_bagger_dir = ${bd_bagger_dir}" 4

    [ ${#BD_BAG_DIRS} -eq 0 ] && BD_BAG_DIRS=()

    local bd_dir_exists=0 # false

    local bd_dir
    for bd_dir in ${BD_BAG_DIRS[@]}; do
        [ ${bd_dir_exists} -eq 1 ] && break
        [ "${bd_dir}" == "${bd_bagger_dir}" ] && bd_dir_exists=1
    done
    unset -v bd_dir

    [ ${bd_dir_exists} -eq 0 ] && BD_BAG_DIRS+=("${bd_bagger_dir}") && bd_debug "bd_bagger_dir = ${bd_bagger_dir}" 2

    unset -v bd_dir_exists
}

# add specific directories listed in a file, via bd_bag & bd_bagger
function bd_bagger_file() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_bagger_file_name="$1"

    bd_debug "bd_bagger_file_name = ${bd_bagger_file_name}" 2

    if [ -r "${bd_bagger_file_name}" ]; then
        local bd_dir

        while read -r bd_dir; do
            bd_debug "1 bd_dir = ${bd_dir}" 4

            # strip comments
            [ "${bd_dir:0:1}" == "#" ] && continue
            bd_dir=${bd_dir%% #*}
            bd_dir=${bd_dir%%#*}
            bd_debug "2 bd_dir = ${bd_dir}" 3

            # safe-ish; eval emulator; only expand ~ to ${HOME}
            [ ${#HOME} -gt 0 ] && [ -r "${HOME}" ] && [ -d "${HOME}" ] && bd_dir="${bd_dir/#\~/$HOME}"
            bd_debug "3 bd_dir = ${bd_dir}" 3

            bd_dir="$(bd_realpath "${bd_dir}")"
            bd_debug "4 bd_dir = ${bd_dir}" 3

            if [[ "${bd_dir}" == *"/"* ]]; then
                # directories
                bd_bagger "${bd_dir}"
            else
                # 'bag' subdirectories
                bd_bag "${bd_dir}"
            fi

        done < "${bd_bagger_file_name}"
        unset -v bd_dir
    fi
    unset -v bd_bagger_file_name
}

# formatted debug output
function bd_debug() {

    [ ${#BD_DEBUG} -eq 0 ] && return 0

    [ ${#1} -eq 0 ] && return 0

    [[ ! "${BD_DEBUG}" =~ ^[0-9]+$ ]] && BD_DEBUG=0
    [ "${BD_DEBUG}" == "0" ] && return 0

    local bd_debug_msg=(${@})

    local bd_debug_level=${bd_debug_msg[${#bd_debug_msg[@]}-1]}
    if [[ "${bd_debug_level}" =~ ^[0-9]+$ ]]; then
        unset bd_debug_msg[${#bd_debug_msg[@]}-1] # remove level from bd_debug_msg; TODO: test with older bash versions
    else
        bd_debug_level=0
    fi

    [ ${BD_DEBUG} -eq 0 ] && [ ${bd_debug_level} -eq 0 ] && return 0

    if [ ${bd_debug_level} -le ${BD_DEBUG} ]; then
        bd_debug_msg="${bd_debug_msg[@]}"

        local bd_debug_bash_source=""
        if [ ${BD_DEBUG} -ge 15 ]; then
            bd_debug_bash_source="${BASH_SOURCE}"
        else
            bd_debug_bash_source="${BASH_SOURCE##*/}"
        fi
        local bd_debug_color
        let bd_debug_color=${bd_debug_level}+11
        printf "$(bd_ansi reset)$(bd_ansi fg${bd_debug_color})[BD_DEBUG:%+2b:%b] [%b] %b$(bd_ansi reset)\n" "${bd_debug_level}" "${BD_DEBUG}" "${bd_debug_bash_source}" "${bd_debug_msg}" 1>&2
    fi

    return 0
}

# colored debug output for milliseconds
function bd_debug_ms() {

    [ ${#1} -eq 0 ] && return 0
    [ ${#BD_DEBUG} -eq 0 ] && return 0
    [ "${BD_DEBUG}" == "0" ] && return 0

    local bd_debug_ms_int=${1} bd_debug_ms_msg

    [[ ! "${bd_debug_ms_int}" =~ ^[0-9]+$ ]] && return

    [ ${bd_debug_ms_int} -le 100 ] && bd_debug_ms_msg="$(bd_ansi fg_green1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 100 ] && bd_debug_ms_msg="$(bd_ansi fg_magenta1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 499 ] && bd_debug_ms_msg="$(bd_ansi fg_yellow1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 999 ] && bd_debug_ms_msg="$(bd_ansi fg_red1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"

    printf "${bd_debug_ms_msg}" # use as subshell; does not output to stderr

    return 0
}

function bd_load() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    [ ${#1} -eq 0 ] && return 1

    local bd_bag_dir bd_loader_finish bd_loader_start bd_loader_total bd_loader_total_ms

    for bd_bag_dir in "${@}"; do
        [ ${#BD_DEBUG} -gt 0 ] && bd_loader_start=$(bd_uptime_ms)

        bd_loader "${bd_bag_dir}"

        if [ ${#BD_DEBUG} -gt 0 ]; then
            bd_loader_finish=$(bd_uptime_ms)
            bd_loader_total=$((${bd_loader_finish}-${bd_loader_start}))
            bd_loader_total_ms="$(bd_debug_ms ${bd_loader_total})"
            bd_debug "bd_loader ${bd_bag_dir} ${bd_loader_total_ms}"
        fi
    done
    unset -v bd_bag_dir bd_loader_finish bd_loader_start bd_loader_total
}

# source everything in a given directory (that ends in .sh)
function bd_loader() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_loader_dir="$1"

    if [ -d "${bd_loader_dir}" ]; then
        local bd_loader_file bd_loader_file_realpath

        local bd_loader_files=()

        # LC_COLLATE consistency hack (due to bsd/darwin differences)
        # https://blog.zhimingwang.org/macos-lc_collate-hunt
        # https://collation-charts.org/fbsd54/

        BD_LC_COLLATE="${LC_COLLATE}"

        LC_COLLATE=POSIX # required for consistent collation across operating systems
        for bd_loader_file in "${bd_loader_dir}"/*\.{bash,sh}; do
            bd_loader_files+=("${bd_loader_file}")
        done
        unset -v bd_loader_file

        [ ${#BD_LC_COLLATE} -gt 0 ] && LC_COLLATE="${BD_LC_COLLATE}" || unset -v LC_COLLATE

        for bd_loader_file in "${bd_loader_files[@]}"; do
            # don't source itself ...
            bd_loader_file_realpath="$(bd_realpath "${BASH_SOURCE}")"
            bd_debug "bd_loader_file_realpath = ${bd_loader_file_realpath}" 31
            [ "${bd_loader_file}" == "${bd_loader_file_realpath}" ] && bd_debug "${FUNCNAME} ${bd_loader_file} matches relative path" 13 && continue # relative location
            [ "${bd_loader_file}" == "${bd_loader_file_realpath##*/}" ] && bd_debug "${FUNCNAME}) ${bd_loader_file} matches basename" 13 && continue # basename

            if [ -r "${bd_loader_file}" ]; then
                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_source_start
                    bd_source_start=$(bd_uptime_ms)
                fi

                source "${bd_loader_file}"

                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_source_finish bd_source_total bd_source_total_ms
                    bd_source_finish=$(bd_uptime_ms)
                    bd_source_total=$((${bd_source_finish}-${bd_source_start}))
                    bd_source_total_ms=$(bd_debug_ms ${bd_source_total})
                    bd_debug "source ${bd_loader_file} ${bd_source_total_ms}" 3
                fi
            fi
        done
        unset -v bd_loader_file bd_loader_files
    fi
}

# semi-portable readlink/realpath
function bd_realpath() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_realpath_arg="$1"

    [ ${#bd_realpath_arg} -eq 0 ] && return 1

    local bd_realpath_basename bd_realpath_dirname bd_realpath_name

    if [ -r "${bd_realpath_arg}" ]; then
        if [ -d "${bd_realpath_arg}" ]; then
            bd_realpath_name="$(cd "${bd_realpath_arg}" &>/dev/null; pwd -P)"
        else
            bd_realpath_dirname="${bd_realpath_arg%/*}"
            if [ -d "${bd_realpath_dirname}" ]; then
                bd_realpath_basename="${bd_realpath_arg##*/}"
                bd_realpath_name="$(cd "${bd_realpath_dirname}" &>/dev/null; pwd -P)"
                bd_realpath_name+="/${bd_realpath_basename}"
            fi
        fi
    fi

    printf "${bd_realpath_name}"
}

# unset & reset initial bashrc
function bd_reload() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    unset -v BD_ID

    [ -r "/etc/bashrc" ] && bd_debug "unset -v BASHRCSOURCED" 2 && unset -v BASHRCSOURCED && source /etc/bashrc
}

# upgrade to the latest version of 00bd.sh (WIP)
function bd_upgrade() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_upgrade_dir="$1"

    if [ -d "${bd_upgrade_dir}" ]; then
        local bd_upgrade_pwd="${PWD}"
        cd "${bd_upgrade_dir}"
        printf "\n# curl ${BD_UPGRADE_URL}\n\n"
        curl --create-dirs --output ${BD_SUB_DIR}/00bd.sh "${BD_UPGRADE_URL}"
        printf "\n"
        cd "${bd_upgrade_pwd}"
        unset -v bd_upgrade_pwd
    fi
}

# output milliseconds since uptime (used for debugging)
function bd_uptime_ms() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local ms t1
    if [ ${BASH_VERSINFO[0]} -ge 5 ]; then
        t1=${EPOCHREALTIME//.}
        ms=$((${t1}/1000))
    else
        local up
        if [ "${BD_OS}" == 'linux' ] || [ "${BD_OS}" == 'windows' ] || [ "${BD_OS}" == 'wsl' ]; then
            local idle
            # linux & windows; use /proc/uptime
            read up idle < /proc/uptime
            t1="${up//.}"
            ms=$((${t1}*10))
        fi

        if [ "${BD_OS}" == 'darwin' ]; then
            # bsd & darwin; use sysctl
            up="$(sysctl -n kern.boottime 2> /dev/null)"
            t1="${up%,*}"
            t1="${t1##* }"
            ms=$((($(date +%s)-${t1})*1000))
        fi
    fi

    printf "${ms}"
}

#
# main
#

bd_debug "${BASH_SOURCE} main"

# determine operating system

BD_OS="unknown"

if type -P uname &> /dev/null; then
    BD_OS_KERNEL_NAME="$(uname -s 2> /dev/null)"

    if [ ${BASH_VERSINFO[0]} -ge 4 ]; then
        BD_OS_KERNEL_NAME=${BD_OS_KERNEL_NAME,,}
    else
        BD_OS_KERNEL_NAME="$(tr [A-Z] [a-z] <<< "${BD_OS_KERNEL_NAME}")" # posix
    fi

    case "${BD_OS_KERNEL_NAME}" in
        bsd*)                       BD_OS='bsd';;
        darwin*)                    BD_OS='darwin';;
        linux*)                     BD_OS='linux';;
        solaris*)                   BD_OS='solaris';;
        cygwin*|mingw*|win*)        BD_OS='windows';;
        linux*microsoft*)           BD_OS='wsl';;
        *)                          BD_OS="unknown:${BD_OS_KERNEL_NAME}"
    esac

    unset -v BD_OS_KERNEL_NAME
fi

export BD_OS

bd_debug "BD_OS = ${BD_OS}" 1

if [ ${#BD_DEBUG} -gt 0 ]; then
    BD_START_TIME=$(bd_uptime_ms)
fi

#
# handle arguments
#

if [ "${1}" == "" ] || [ "${1}" == "reload" ]; then
    bd_debug "${BASH_SOURCE} reload"

    bd_reload
fi

[ "${BD_ID}" != "" ] && return 0 # prevent multiple executions (due to recursive links, etc); or, to prevent execution, set BD_ID

# prevent concurrent executions

BD_ID=''

if [ ${BASH_VERSINFO[0]} -ge 4 ]; then
    printf -v BD_ID '%(%y%m%d%H%M%S%z)T'
else
    if type -P date &> /dev/null; then
        BD_ID="$(date +%y%m%d%H%M%S%z)" # posix
    else
        BD_ID='loaded'
    fi
fi

export BD_ID

#
# 0 - export BD_USER & BD_HOME; (WIP)
#

[ "${EUID}" == "0" ] && USER=root

[ "${USER}" != "root" ] && unset BD_USER # honor sudo --preserve-env=BD_USER

# preferred order of sources for BD_USER
[ ${#BD_USER} -eq 0 ] && [ -f ~/.BD_USER ] && BD_USER="$(head -1 ~/.BD_USER | tr -d '\n')" # bypass with a config file; TODO: use ~/.config or something else
[ ${#BD_USER} -eq 0 ] && [ "${USER}" == "root" ] && type -P logname &> /dev/null && BD_USER=$(logname 2> /dev/null) # hack; only use logname for root?
[ ${#BD_USER} -eq 0 ] && [ ${#USER} -gt 0 ] && BD_USER=${USER} # default to ${USER}
[ ${#BD_USER} -eq 0 ] && [ ${#USERNAME} -gt 0 ] && BD_USER=${USERNAME}
[ ${#BD_USER} -eq 0 ] && type -P who &> /dev/null && BD_USER=$(who -m 2> /dev/null)
[ ${#BD_USER} -eq 0 ] && [ ${#SUDO_USER} -gt 0 ] && BD_USER=${SUDO_USER}
[ ${#BD_USER} -eq 0 ] && [ ${#LOGNAME} -gt 0 ] && BD_USER=${LOGNAME}

[ ${#USER} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && USER=${BD_USER}

export BD_USER

[ "${USER}" != "root" ] && unset BD_HOME # honor sudo --preserve-env=BD_HOME

[ ${#BD_USER} -eq 0 ] && BD_HOME="/tmp"

# preferred order of sources for BD_HOME
[ ${#BD_HOME} -eq 0 ] && [ -f ~/.BD_HOME ] && BD_HOME="$(head -1 ~/.BD_HOME | tr -d '\n')" # bypass with a config file; TODO: use ~/.config or something else
[ ${#BD_HOME} -eq 0 ] && [ ${#HOME} -gt 0 ] && BD_HOME=${HOME} # default to ${HOME}
[ ${#BD_HOME} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && type -P getent &> /dev/null && BD_HOME=$(getent passwd ${BD_USER} 2> /dev/null) && BD_HOME=${BD_HOME%%:*}
[ ${#BD_HOME} -eq 0 ] && BD_HOME="~"

export BD_HOME

BD_BAG_DIRS=()

bd_debug "BASH_SOURCE=${BASH_SOURCE}" 5

#
# 1 - bd_bag bd extensions subdirectory (a built in bag; WIP)
#

bd_bag "bd"

#
# 2 - bd_bagger system root, /${BD_SUB_DIR}
#

[ -r "/${BD_SUB_DIR}" ] && [ -d "/${BD_SUB_DIR}" ] && bd_bagger "/${BD_SUB_DIR}"

#
# 3 - bd_bag <username> subdirectories
#

[ ${#BD_USER} -gt 0 ] && [ "${BD_USER}" != "${LOGNAME}" ] && bd_bag "${BD_USER}"
[ ${#USER} -gt 0 ] && [ "${USER}" != "${LOGNAME}" ] && bd_bag "${USER}"
[ ${#USERNAME} -gt 0 ] && [ "${USERNAME}" != "${LOGNAME}" ] && bd_bag "${USERNAME}"
[ ${#LOGNAME} -gt 0 ] && bd_bag "${LOGNAME}" # posix

# if BD_HOME is not set (externaly), then nothing will happen
if [ "${BD_HOME}" != "${HOME}" ]; then
    if [ ${#BD_HOME} -gt 0 ] && [ "${BD_HOME}" != "/" ]; then
        bd_debug "BD_HOME = ${BD_HOME}" 1
        [ -r "${BD_HOME}/${BD_CONF_FILE}" ] && [ -f "${BD_HOME}/${BD_CONF_FILE}" ] && bd_bagger_file "${BD_HOME}/${BD_CONF_FILE}"
        [ -r "${BD_HOME}/${BD_SUB_DIR}" ] && [ -d "${BD_HOME}/${BD_SUB_DIR}" ] && bd_bagger "${BD_HOME}/${BD_SUB_DIR}"
    fi
fi

export BD_HOME

#
# 4 - add $HOME via bd_bagger & bd_bagger_file
#

# HOME may or may not be set, e.g. su & sudo preserve environment, etc
if [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ]; then
    bd_debug "HOME = ${HOME}" 4
    [ -r "${HOME}/${BD_CONF_FILE}" ] && [ -f "${HOME}/${BD_CONF_FILE}" ] && bd_bagger_file "${HOME}/${BD_CONF_FILE}"
    [ -r "${HOME}/${BD_SUB_DIR}" ] && [ -d "${HOME}/${BD_SUB_DIR}" ] && bd_bagger "${HOME}/${BD_SUB_DIR}"
fi

#
# 5 - add current working directory via bd_bagger
#

if [ -d "${PWD}/${BD_SUB_DIR}" ]; then
    bd_bagger "${PWD}/${BD_SUB_DIR}"
fi

bd_debug "BD_BAG_DIRS = ${BD_BAG_DIRS[@]}" 1

#
# 6 - set environment aliases
#

bd_aliases

#
# 7 - autoload all bagged directories
#

bd_load "${BD_BAG_DIRS[@]}"

if [ ${#BD_DEBUG} -gt 0 ]; then
    BD_FINISH_TIME=$(bd_uptime_ms)
    BD_TOTAL_TIME=$((${BD_FINISH_TIME}-${BD_START_TIME}))
    BD_TOTAL_TIME_MS="$(bd_debug_ms ${BD_TOTAL_TIME})"

    bd_debug "${BASH_SOURCE} finished ${BD_TOTAL_TIME_MS}" 0

    unset -v BD_FINISH_TIME BD_START_TIME BD_TOTAL_TIME BD_TOTAL_TIME_MS
fi
