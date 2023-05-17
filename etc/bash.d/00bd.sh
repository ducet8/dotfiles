# 00bd.sh: bash directory (bash.d) autoloader

# https://github.com/bash-d/bd/blob/main/README.md

# Copyright (C) 2018-2023 Joseph Tingiris <joseph.tingiris@gmail.com>
# https://github.com/bash-d/bd/blob/main/LICENSE.md

#
# metadata
#

# bash.d: exports BD_BASH_INIT_FILE BD_DEBUG BD_DIR BD_HOME BD_ID BD_OS BD_SOURCE BD_USER BD_VERSION

#
# init
#

export BD_VERSION=0.40.1

# prevent non-bash bourne compatible shells
[ "${BASH_SOURCE}" == "" ] && return &> /dev/null

# prevent non-sourced execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (instead, 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

#
# functions
#

# set bd aliases
function bd_aliases() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    if [ -r "${BD_DIR}/bin/bd-ansi" ]; then
        [ ! -x "${BD_DIR}/bin/bd-ansi" ] && chmod u+x "${BD_DIR}/bin/bd-ansi"
        if "${BD_DIR}/bin/bd-ansi" reset &> /dev/null; then
            alias bd-ansi="${BD_DIR}/bin/bd-ansi"
        else
            alias bd-ansi=false
        fi
    else
        alias bd-ansi=false
    fi

    if [ -r "${BD_DIR}/bin/bd-debug" ]; then
        [ ! -x "${BD_DIR}/bin/bd-debug" ] && chmod u+x "${BD_DIR}/bin/bd-debug"
        alias bd-debug="${BD_DIR}/bin/bd-debug"
    else
        alias bd-debug=false
    fi

    # handle missing functions
    if ! type -t bd_debug &> /dev/null; then
        alias bd_debug=bd-debug
    fi

    [ "${BD_BASH_INIT_FILE}" != "" ] && [ -r "${BD_BASH_INIT_FILE}" ] && alias bd="source '${BD_BASH_INIT_FILE}'"
}

# call bd_autoloader on an array (of directories)
function bd_autoload() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    [ ${#1} -eq 0 ] && return 1

    local bd_bag_dir bd_loader_finish bd_loader_start bd_loader_total bd_loader_total_ms

    for bd_bag_dir in "${@}"; do
        [ ${#BD_DEBUG} -gt 0 ] && bd_loader_start=$(bd_uptime_ms)

        bd_autoloader "${bd_bag_dir}"

        if [ ${#BD_DEBUG} -gt 0 ]; then
            bd_loader_finish=$(bd_uptime_ms)
            bd_loader_total=$((${bd_loader_finish}-${bd_loader_start}))
            bd_loader_total_ms="$(bd_debug_ms ${bd_loader_total})"
            bd_debug "bd_autoloader ${bd_bag_dir} ${bd_loader_total_ms}"
        fi
    done
    unset -v bd_bag_dir bd_loader_finish bd_loader_start bd_loader_total
}

# source everything in a given directory (that ends in .sh)
function bd_autoloader() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_loader_dir="$1"

    if [ -d "${bd_loader_dir}" ]; then
        local bd_loader_file bd_loader_file_realpath

        local bd_loader_files=()

        # LC_COLLATE consistency hack (due to bsd/darwin differences)
        # https://blog.zhimingwang.org/macos-lc_collate-hunt
        # https://collation-charts.org/fbsd54/

        local bd_lc_collate="${LC_COLLATE}"

        LC_COLLATE=POSIX # required for consistent collation across operating systems
        for bd_loader_file in "${bd_loader_dir}"/*\.{bash,sh}; do
            bd_loader_files+=("${bd_loader_file}")
        done
        unset -v bd_loader_file

        [ ${#bd_lc_collate} -gt 0 ] && LC_COLLATE="${bd_lc_collate}" || unset -v LC_COLLATE

        for bd_loader_file in "${bd_loader_files[@]}"; do

            # don't source itself ...
            [ "${bd_loader_file}" == "${BD_SOURCE}" ] && bd_debug "${FUNCNAME} ${bd_loader_file} matches relative path" 13 && continue # relative location
            [ "${bd_loader_file}" == "${BD_SOURCE##*/}" ] && bd_debug "${FUNCNAME}) ${bd_loader_file} matches basename" 13 && continue # basename

            if [ -r "${bd_loader_file}" ]; then
                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_source_start
                    bd_source_start=$(bd_uptime_ms)
                fi

                bd_debug "source  ${bd_loader_file} ..." 4

                source "${bd_loader_file}" "" # pass an empty arg to $1

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

# add a specific subdirectory via bd_bagger; a single 'bag' is simply a subdirectory in ${BD_PATH}
function bd_bag() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_bag_name="$1"

    local bag_dir bag_dirs

    bag_dirs=()

    [ "${bd_bag_name}" == "bash.d" ] && bag_dirs+=("${BD_DIR}/${bd_bag_name}")

    bag_dirs+=("/${BD_BAG_DIR}/${bd_bag_name}")

    [ "${BD_HOME}" != "${HOME}" ] && bag_dirs+=("${BD_HOME}/${BD_BAG_DIR}/${bd_bag_name}")
    [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ] && bag_dirs+=("${HOME}/${BD_BAG_DIR}/${bd_bag_name}")

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

# add BD_ environment variables from config file
function bd_config_file() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_config_file_name="$1"

    # TODO: parse config file & export variables
    if [ -r "${bd_config_file_name}" ]; then
        #grep ^BD_ "${bd_config_file_name}"
        bd_debug "WIP" 99
    fi
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
        unset -v bd_debug_msg[${#bd_debug_msg[@]}-1] # remove level from bd_debug_msg; TODO: test with older bash versions
    else
        bd_debug_level=0
    fi

    [ ${BD_DEBUG} -eq 0 ] && [ ${bd_debug_level} -eq 0 ] && return 0

    if [ ${bd_debug_level} -le ${BD_DEBUG} ]; then
        bd_debug_msg="${bd_debug_msg[@]}"

        local bd_debug_bash_source=""
        local bd_debug_color

        if [ ${BD_DEBUG} -ge 15 ]; then
            bd_debug_bash_source="${BD_SOURCE}"
        else
            bd_debug_bash_source="${BD_SOURCE##*/}"
        fi

        [ ${bd_debug_level} -eq 1 ] && bd_debug_color="_gray1"
        [ ${bd_debug_level} -eq 2 ] && bd_debug_color="_white1"
        [ ${bd_debug_level} -eq 3 ] && bd_debug_color="_cyan1"
        [ ${bd_debug_level} -eq 4 ] && bd_debug_color="_magenta1"
        [ ${bd_debug_level} -eq 5 ] && bd_debug_color="_blue1"
        [ ${bd_debug_level} -eq 6 ] && bd_debug_color="_yellow1"
        [ ${bd_debug_level} -eq 7 ] && bd_debug_color="_green1"
        [ ${bd_debug_level} -eq 8 ] && bd_debug_color="_red1"

        [ ${#bd_debug_color} -eq 0 ] && let bd_debug_color=${bd_debug_level}+11

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

# unset functions & variables
function bd_unset() {
    local bd_function bd_functions=()

    bd_functions+=(bd_aliases)
    if [ "${BD_ANSI_EXPORT}" == "1" ] || [ "${BD_ANSI_EXPORT}" == "true" ]; then
        export -f bd_ansi
    else
        bd_functions+=(bd_ansi)
    fi
    bd_functions+=(bd_ansi_chart)
    bd_functions+=(bd_ansi_chart_16)
    bd_functions+=(bd_ansi_chart_16_bg)
    bd_functions+=(bd_ansi_chart_16_fg)
    bd_functions+=(bd_ansi_chart_256)
    bd_functions+=(bd_ansi_chart_256_bg)
    bd_functions+=(bd_ansi_chart_256_fg)
    bd_functions+=(bd_autoload)
    bd_functions+=(bd_autoloader)
    bd_functions+=(bd_bag)
    bd_functions+=(bd_bagger)
    bd_functions+=(bd_bagger_file)
    bd_functions+=(bd_config_file)
    bd_functions+=(bd_debug)
    bd_functions+=(bd_debug_ms)
    bd_functions+=(bd_realpath)
    bd_functions+=(bd_reload)
    bd_functions+=(bd_upgrade)
    bd_functions+=(bd_uptime_ms)

    #for bd_function in $(declare -F 2> /dev/null); do
    for bd_function in ${bd_functions[@]}; do
        if [[ "${bd_function}" == "bd_"* ]] && [ "${bd_function}" != "bd_unset" ]; then
            unset -f "${bd_function}"
        fi
    done
    unset -v bd_function

    unset -f bd_unset
}

# upgrade to the latest version of 00bd.sh (WIP)
function bd_upgrade() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_upgrade_dir="$1"

    if [ -d "${bd_upgrade_dir}" ]; then
        local bd_upgrade_pwd="${PWD}"

        cd "${bd_upgrade_dir}"

        if [ -d .git ]; then
            git remote -v && echo && git pull && echo
        else
            printf "\n# curl ${BD_UPGRADE_URL}\n\n"
            curl --create-dirs --output ${BD_BAG_DIR}/00bd.sh "${BD_UPGRADE_URL}"
            printf "\n"
        fi

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

# stub bd_ansi (for embedded bd_debug)
if ! type -t bd_ansi &> /dev/null; then
    function bd_ansi() {
        return
    }
fi

# handle dirs argument
if [ "${1}" == "dir" ] || [ "${1}" == "dirs" ]; then
    echo "${BD_BAG_DIRS[@]}"

    return 0
fi

# handle env argument
if [ "${1}" == "env" ]; then
    bd_debug "${BD_SOURCE} env" 1

    # TODO: sort/uniq this ...
    for BD_DECLARE in $(declare 2> /dev/null); do
        if [[ "${BD_DECLARE}" == 'BD_'*'='* ]]; then
            BD_VAR="${BD_DECLARE%%=*}"
            [[ "${BD_VAR}" == *'+'* ]] && continue
            [ "${BD_VAR}" == "BD_DECLARE" ] && continue
            [ "${BD_VAR}" == "BD_VAR" ] && continue
            printf "%-30s = %s\n" "${BD_VAR}" "${!BD_VAR}"
        fi
    done
    unset -v BD_DECLARE BD_VAR

    return $?
fi

# handle functions argument
if [ "${1}" == "functions" ]; then
    return $?
fi

# handle license argument
if [ "${1}" == "license" ]; then
    bd_debug "${BD_SOURCE} license" 1

    # if it's readable then display the included license
    if [ -r "${BD_DIR}/bin/bd-license" ]; then
        if [ -x "${BD_DIR}/bin/bd-license" ]; then
            "${BD_DIR}/bin/bd-license"
        else
            BD_ECHO_LICENSE=1 source "${BD_DIR}/bin/bd-license"
        fi
    else
        printf "\n'${BD_DIR}/bin/bd-license' file not found readable; see https://github.com/bash-d/bd/blob/main/LICENSE.md\n\n"

        return 1
    fi

    return 0
fi

# handle update/upgrade argument
if [ "${1}" == "update" ] || [ "${1}" == "upgrade" ]; then
    BD_UPDATE_URL="https://raw.githubusercontent.com/bash-d/bd/main/00bd.sh"

    bd_debug "${BD_SOURCE} upgrade" 1

    bd_upgrade "${BD_DIR}"

    return $?
fi

# bypass unhandled arguments
[ ${#1} -gt 0 ] && return

# set common globals

BD_CONFIG_FILES=".bash.d.conf .bd.conf"

BD_BAG_DIR="etc/bash.d"

export BD_00BD_SH="${BASH_SOURCE}"
export BD_SOURCE="$(bd_realpath "${BD_00BD_SH}")"
export BD_DIR="${BD_SOURCE%/*}"

export BD_DEBUG=${BD_DEBUG:-0} # level >0 enables debugging

bd_debug "${BD_SOURCE} started"

bd_debug "BD_00BD_SH = ${BD_00BD_SH}" 2
bd_debug "BD_DIR = ${BD_DIR}" 2
bd_debug "BD_SOURCE = ${BD_SOURCE}" 2

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
    bd_debug "${BD_SOURCE} reload"

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
# 0 - export BD_USER, BD_HOME, & BD_BASH_INIT_FILE; (WIP)
#

for BD_CONFIG_FILE in ${BD_CONFIG_FILES}; do
    [ -f "${BD_HOME}/${BD_CONFIG_FILE}" ] && [ -r "${BD_HOME}/${BD_CONFIG_FILE}" ] && bd_config_file "${BD_HOME}/${BD_CONFIG_FILE}" && break
    [ -f "${HOME}/${BD_CONFIG_FILE}" ] && [ -r "${HOME}/${BD_CONFIG_FILE}" ] && bd_config_file "${HOME}/${BD_CONFIG_FILE}" && break
    [ -f "${PWD}/${BD_CONFIG_FILE}" ] && [ -r "${PWD}/${BD_CONFIG_FILE}" ] && bd_config_file "${PWD}/${BD_CONFIG_FILE}" && break
done

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

# TODO: should .bash_profile be first? (.bashrc works for me)
[ "${BD_BASH_INIT_FILE}" == "" ] && [ -r "${BD_HOME}/.bashrc" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bashrc"
[ "${BD_BASH_INIT_FILE}" == "" ] && [ -r "${BD_HOME}/.bash_profile" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bash_profile"

export BD_BASH_INIT_FILE

BD_BAG_DIRS=()

#
# 1 - bd_bag bd extensions (e.g. built in bags; WIP)
#

bd_bag "bash.d"

#
# 2 - bd_bagger /etc
#

[ -f "/etc/bd.conf" ] && [ -r "/etc/bd.conf" ] && bd_bagger_file "/etc/bd.conf"

if [ -r "/${BD_BAG_DIR}" ] && [ -d "/${BD_BAG_DIR}" ]; then
    bd_bagger "/${BD_BAG_DIR}"

    for BD_BAGGER_DIR in "/${BD_BAG_DIR}"/*; do
        [ -d "${BD_BAGGER_DIR}" ] && [ -r "${BD_BAGGER_DIR}" ] && bd_bagger "${BD_BAGGER_DIR}"
    done
    unset -v BD_BAGGER_DIR
fi

#
# 3 - bd_bagger ${BD_HOME}
#

if [ "${BD_HOME}" != "${HOME}" ]; then
    if [ ${#BD_HOME} -gt 0 ] && [ "${BD_HOME}" != "/" ]; then
        bd_debug "BD_HOME = ${BD_HOME}" 4

        for BD_CONFIG_FILE in ${BD_CONFIG_FILES}; do
            [ -f "${BD_HOME}/${BD_CONFIG_FILE}" ] && [ -r "${BD_HOME}/${BD_CONFIG_FILE}" ] && bd_bagger_file "${BD_HOME}/${BD_CONFIG_FILE}" && break
        done
        unset -v BD_CONFIG_FILE

        [ -d "${BD_HOME}/${BD_BAG_DIR}" ] && [ -r "${BD_HOME}/${BD_BAG_DIR}" ] && bd_bagger "${BD_HOME}/${BD_BAG_DIR}"

        for BD_BAGGER_DIR in "${BD_HOME}/${BD_BAG_DIR}"/*; do
            [ -d "${BD_BAGGER_DIR}" ] && [ -r "${BD_BAGGER_DIR}" ] && bd_bagger "${BD_BAGGER_DIR}"
        done
        unset -v BD_BAGGER_DIR
    fi
fi

#
# 4 - bd_bagger ${HOME}
#

# HOME may or may not be set, e.g. su & sudo preserve environment, etc
if [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ]; then
    bd_debug "HOME = ${HOME}" 4

    for BD_CONFIG_FILE in ${BD_CONFIG_FILES}; do
        [ -f "${HOME}/${BD_CONFIG_FILE}" ] && [ -r "${HOME}/${BD_CONFIG_FILE}" ] && bd_bagger_file "${HOME}/${BD_CONFIG_FILE}" && break
    done
    unset -v BD_CONFIG_FILE

    [ -d "${HOME}/${BD_BAG_DIR}" ] && [ -r "${HOME}/${BD_BAG_DIR}" ] && bd_bagger "${HOME}/${BD_BAG_DIR}"

    for BD_BAGGER_DIR in "${HOME}/${BD_BAG_DIR}"/*; do
        [ -d "${BD_BAGGER_DIR}" ] && [ -r "${BD_BAGGER_DIR}" ] && bd_bagger "${BD_BAGGER_DIR}"
    done
    unset -v BD_BAGGER_DIR
fi

#
# 5 - add current working directory via bd_bagger
#

for BD_CONFIG_FILE in ${BD_CONFIG_FILES}; do
    [ -f "${PWD}/${BD_CONFIG_FILE}" ] && [ -r "${PWD}/${BD_CONFIG_FILE}" ] && bd_bagger_file "${PWD}/${BD_CONFIG_FILE}" && break
done
unset -v BD_CONFIG_FILE

if [ -d "${PWD}/${BD_BAG_DIR}" ] && [ -r "${PWD}/${BD_BAG_DIR}" ]; then
    bd_bagger "${PWD}/${BD_BAG_DIR}"
fi

bd_debug "BD_BAG_DIRS = ${BD_BAG_DIRS[@]}" 1

#
# 6 - set environment aliases
#

bd_aliases

#
# 7 - autoload all bagged directories
#

bd_autoload "${BD_BAG_DIRS[@]}"

if [ ${#BD_DEBUG} -gt 0 ]; then
    BD_FINISH_TIME=$(bd_uptime_ms)
    BD_TOTAL_TIME=$((${BD_FINISH_TIME}-${BD_START_TIME}))
    BD_TOTAL_TIME_MS="$(bd_debug_ms ${BD_TOTAL_TIME})"

    bd_debug "${BD_SOURCE} finished ${BD_TOTAL_TIME_MS}" 0

    unset -v BD_FINISH_TIME BD_START_TIME BD_TOTAL_TIME BD_TOTAL_TIME_MS
fi

#
# * - unset included bd_ functions
#

bd_unset
