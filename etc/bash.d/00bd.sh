# Copyright (c) 2022 Joseph Tingiris
# https://github.com/bash-d/bd/blob/main/LICENSE.md

# 00bd.sh: an out-of-bag themed, machine learning directory autoloader for bash shell source

# https://github.com/bash-d/bd/blob/main/README.md

BD_VERSION=0.30

# prevent non-bash shells (for now)
[ "${BASH_SOURCE}" == "" ] && return &> /dev/null

# prevent non-sourced execution (for now; function bd_status(), etc. later ...)
if [ ${0} == ${BASH_SOURCE} ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (instead, 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

#
# globals
#

BD_CONF_FILE='.bash.d.conf'
BD_SUB_DIR='etc/bash.d'
BD_UPDATE_URL='https://raw.githubusercontent.com/bash-d/bd/main/00bd.sh'

SHELL="${SHELL:-$(command -v sh 2> /dev/null)}"

export BD_DEBUG=${BD_DEBUG:-0} # level >0 enables debugging

#
# functions
#

# update bd aliases
function bd_aliases() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    alias bd="source ${BD_HOME}/.bashrc reload"
}

# add a specific subdirectory via bd_bagger; a single 'bag' is simply a subdirectory in ${BD_PATH}
function bd_bag() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_bag_name="$1"

    local bag_dir bag_dirs

    bag_dirs=()

    bag_dirs+=("/${BD_SUB_DIR}/${bd_bag_name}")

    [ "${BD_HOME}" != "${HOME}" ] && bag_dirs+=("${BD_HOME}/${BD_SUB_DIR}/${bd_bag_name}")
    [ ${#HOME} -gt 0 ] && [ "${HOME}" != '/' ] && bag_dirs+=("${HOME}/${BD_SUB_DIR}/${bd_bag_name}")

    for bag_dir in ${bag_dirs[@]}; do
        bag_dir=${bag_dir//\/\//\/}
        bd_debug "1 bag_dir = ${bag_dir} [bag]" 3

        bag_dir="$(bd_realdir "${bag_dir}")"
        bd_debug "2 bag_dir = ${bag_dir} [bag]" 3

        bd_bagger "${bag_dir}"
    done

    unset bag_dir
}

# add unique, existing directories to the global BD_BAG_DIRS array (& preserve the natural order)
function bd_bagger() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_bagger_dir="${1//\/\//\/}"

    bd_debug "1 bd_bagger_dir = ${bd_bagger_dir}" 3

    [ -z "${bd_bagger_dir}" ] && return 1

    [ ! -d "${bd_bagger_dir}" ] && return 1

    bd_bagger_dir="$(bd_realdir "${bd_bagger_dir}")"
    bd_debug "2 bd_bagger_dir = ${bd_bagger_dir}" 4

    [ -z "${BD_BAG_DIRS}" ] && BD_BAG_DIRS=()

    local bd_dir_exists=0 # false

    local bd_dir
    for bd_dir in ${BD_BAG_DIRS[@]}; do
        [ ${bd_dir_exists} -eq 1 ] && break
        [ "${bd_dir}" == "${bd_bagger_dir}" ] && bd_dir_exists=1
    done
    unset bd_dir

    [ ${bd_dir_exists} -eq 0 ] && BD_BAG_DIRS+=("${bd_bagger_dir}") && bd_debug "bd_bagger_dir = ${bd_bagger_dir}" 2

    unset bd_dir_exists
}

# add specific directories listed in a file, via bd_bag & bd_bagger
function bd_bagger_file() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_bagger_file_name="$1"

    bd_debug "bd_bagger_file_name = ${bd_bagger_file_name}" 2

    if [ -r "${bd_bagger_file_name}" ]; then
        local bd_dir
        while read bd_dir; do
            bd_debug "1 bd_dir = ${bd_dir}" 3

            # strip comments
            [ ${bd_dir:0:1} == "#" ] && continue
            bd_dir=${bd_dir%% #*}
            bd_dir=${bd_dir%%#*}
            bd_debug "2 bd_dir = ${bd_dir}" 3

            # safe-ish; eval emulator; only expand ~ to ${HOME}
            [ ${#HOME} -gt 0 ] && [ -r "${HOME}" ] && [ -d "${HOME}" ] && bd_dir="${bd_dir/#\~/$HOME}"
            bd_debug "3 bd_dir = ${bd_dir}" 3

            bd_dir="$(bd_realdir "${bd_dir}")"
            bd_debug "4 bd_dir = ${bd_dir}" 3

            if [[ "${bd_dir}" == *"/"* ]]; then
                # directories
                bd_bagger "${bd_dir}"
            else
                # 'bag' subdirectories
                bd_bag "${bd_dir}"
            fi

        done < "${bd_bagger_file_name}"
        unset bd_dir
    fi
    unset bd_bagger_file_name
}

# formatted debug output
function bd_debug() {

    [ -z "${1}" ] && return 0
    [ -z "${BD_DEBUG}" ] && return 0
    [ "${BD_DEBUG}" == '0' ] && return 0

    local debug_msg=(${@})

    [[ ! "${BD_DEBUG}" =~ ^[0-9]+$ ]] && BD_DEBUG=0

    local debug_level=${debug_msg[${#debug_msg[@]}-1]}
    if [[ "${debug_level}" =~ ^[0-9]+$ ]]; then
        unset debug_msg[${#debug_msg[@]}-1] # remove level from debug_msg; TODO: test with older bash versions
    else
        debug_level=0
    fi

    [ ${BD_DEBUG} -eq 0 ] && [ ${debug_level} -eq 0 ] && return 0

    if [ ${debug_level} -le ${BD_DEBUG} ]; then
        debug_msg="${debug_msg[@]}"

        local debug_src=""
        if [ ${BD_DEBUG} -ge 15 ]; then
            debug_src="${BASH_SOURCE}"
        else
            debug_src="${BASH_SOURCE##*/}"
        fi
        printf "[BD_DEBUG:%+2b:%b] [%b] %b\n" "${debug_level}" "${BD_DEBUG}" "${debug_src}" "${debug_msg}" 1>&2
    fi

    return 0
}

function bd_load() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    [ -z "${1}" ] && return 1

    local bd_bag_dir bd_loader_finish bd_loader_start bd_loader_total
    for bd_bag_dir in "${@}"; do
        [ ${#BD_DEBUG} -gt 0 ] && bd_loader_start=$(bd_uptime_ms)
        bd_loader "${bd_bag_dir}"
        if [ ${#BD_DEBUG} -gt 0 ]; then
            bd_loader_finish=$(bd_uptime_ms)
            bd_loader_total=$((${bd_loader_finish}-${bd_loader_start}))
            bd_debug "bd_loader ${bd_bag_dir} [${bd_loader_total}ms]"
        else
            bd_debug "bd_loader ${bd_bag_dir}"
        fi
    done
    unset bd_bag_dir bd_loader_finish bd_loader_start bd_loader_total
}

# source everything in a given directory (that ends in .sh)
function bd_loader() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_loader_dir="$1"

    if [ -d "${bd_loader_dir}" ]; then
        [ ! -x "${SHELL}" ] && return 1

        local bd_dir_sh
        for bd_dir_sh in "${bd_loader_dir}"/*.sh ; do

            # don't source itself ...
            [ "${bd_dir_sh}" == "${BASH_SOURCE}" ] && continue
            [ "${bd_dir_sh}" == "${BD_SOURCE}" ] && continue

            if [ -r "${bd_dir_sh}" ]; then
                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_source_finish bd_source_start bd_source_total
                    bd_source_start=$(bd_uptime_ms)
                fi

                source "${bd_dir_sh}"

                if [ ${#BD_DEBUG} -gt 0 ]; then
                    bd_source_finish=$(bd_uptime_ms)
                    bd_source_total=$((${bd_source_finish}-${bd_source_start}))
                    bd_debug "source ${bd_dir_sh} [${bd_source_total}ms]" 2
                fi
            fi
        done
        unset -v bd_dir_sh
    fi
}

# semi-portable readlink/realpath
function bd_realdir() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_realdir_name="$1"

    [ -z "${bd_realdir_name}" ] && return 1

    [ -r "${bd_realdir_name}" ] && [ -d "${bd_realdir_name}" ] && bd_realdir_name="$(cd "${bd_realdir_name}" &>/dev/null; pwd -P)"

    printf "${bd_realdir_name}"
}

# unset & reset initial bashrc
function bd_reload() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    unset BD_ID
    [ -r '/etc/bashrc' ] && bd_debug 'unset BASHRCSOURCED' 2 && unset BASHRCSOURCED && source /etc/bashrc
}

# upgrade to the latest version of 00bd.sh
function bd_update() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local bd_update_dir="$1"

    if [ -d "${bd_update_dir}" ]; then
        local here="${PWD}"
        cd "${bd_update_dir}"
        printf "\n# curl ${BD_UPDATE_URL}\n\n"
        curl --create-dirs --output ${BD_SUB_DIR}/00bd.sh "${BD_UPDATE_URL}"
        printf "\n"
        cd "${here}"
        unset here
    fi
}

# output milliseconds since uptime (used for debugging)
function bd_uptime_ms() {
    bd_debug "function ${FUNCNAME}(${@})" 15

    local ms t1
    if [ -r /proc/uptime ]; then
        # linux; use uptime
        read up rest < /proc/uptime; t1="${up%.*}${up#*.}"
        ms=$(( 10*(t1) ))
    else
        # mac
        boottime=$(sysctl -n kern.boottime | cut -d" " -f4 | cut -d"," -f1)
        ms=$(( 1000*($(date +%s) - ${boottime}) ))
    fi
    printf "${ms}"
}

#
# main
#

bd_debug started

#
# handle arguments
#

if [ "${1}" == 'reload' ]; then
    bd_debug reload

    bd_reload
fi

if [ "${1}" == 'update' ]; then
    bd_debug update

    bd_update

    return $?
fi

[ ${BD_ID} ] && return 0 # prevent multiple executions (due to recursive links, etc); or, to prevent execution, set BD_ID

#
# init
#

bd_debug init

printf -v BD_ID '%(%y%m%d%H%M%S%z)T' && export BD_ID # prevent concurrent executions

#
# 0 - export BD_USER & BD_HOME; (WIP)
#

[ "${EUID}" == '0' ] && USER=root

[ "${USER}" != 'root' ] && unset BD_USER # honor sudo --preserve-env=BD_USER

# preferred order of sources for BD_USER
[ -z ${BD_USER} ] && [ -f ~/.BD_USER ] && BD_USER="$(head -1 ~/.BD_USER | tr -d '\n')" # bypass with a config file; TODO: use ~/.config or something else
[ -z ${BD_USER} ] && [ "${USER}" == 'root' ] && type -P logname &> /dev/null && BD_USER=$(logname 2> /dev/null) # hack; only use logname for root?
[ -z ${BD_USER} ] && [ ${#USER} -gt 0 ] && BD_USER=${USER} # default to ${USER}
[ -z ${BD_USER} ] && [ ${#USERNAME} -gt 0 ] && BD_USER=${USERNAME}
[ -z ${BD_USER} ] && type -P who &> /dev/null && BD_USER=$(who -m 2> /dev/null)
[ -z ${BD_USER} ] && [ ${#SUDO_USER} -gt 0 ] && BD_USER=${SUDO_USER}
[ -z ${BD_USER} ] && [ ${#LOGNAME} -gt 0 ] && BD_USER=${LOGNAME}

[ -z ${USER} ] && [ ${#BD_USER} -gt 0 ] && USER=${BD_USER}

export BD_USER

[ "${USER}" != 'root' ] && unset BD_HOME # honor sudo --preserve-env=BD_HOME

[ -z ${BD_USER} ] && BD_HOME='/tmp'

# preferred order of sources for BD_HOME
[ -z ${BD_HOME} ] && [ -f ~/.BD_HOME ] && BD_HOME="$(head -1 ~/.BD_HOME | tr -d '\n')" # bypass with a config file; TODO: use ~/.config or something else
[ -z ${BD_HOME} ] && [ ${#HOME} -gt 0 ] && BD_HOME=${HOME} # default to ${HOME}
[ -z ${BD_HOME} ] && [ ${#BD_USER} -gt 0 ] && type -P getent &> /dev/null && BD_HOME=$(getent passwd ${BD_USER} 2> /dev/null) && BD_HOME=${BD_HOME%%:*}
[ -z ${BD_HOME} ] && BD_HOME='~'

export BD_HOME

BD_BAG_DIRS=()

bd_debug "BASH_SOURCE=${BASH_SOURCE}" 5

#
# 1 - bd_bag bd extensions subdirectory (a built in bag; WIP)
#

bd_bag 'bd'

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
[ ${#LOGNAME} -gt 0 ] && bd_bag "${LOGNAME}" # LOGNAME is posix

# if BD_HOME is not set (externaly), then nothing will happen
if [ "${BD_HOME}" != "${HOME}" ]; then
    if [ ${#BD_HOME} -gt 0 ] && [ "${BD_HOME}" != '/' ]; then
        bd_debug "BD_HOME = ${BD_HOME}"
        [ -r "${BD_HOME}/${BD_CONF_FILE}" ] && [ -f "${BD_HOME}/${BD_CONF_FILE}" ] && bd_bagger_file "${BD_HOME}/${BD_CONF_FILE}"
        [ -r "${BD_HOME}/${BD_SUB_DIR}" ] && [ -d "${BD_HOME}/${BD_SUB_DIR}" ] && bd_bagger "${BD_HOME}/${BD_SUB_DIR}"
    fi
fi

#
# 4 - add $HOME via bd_bagger & bd_bagger_file
#

# HOME may or may not be set, e.g. su & sudo preserve environment, etc
if [ ${#HOME} -gt 0 ] && [ "${HOME}" != '/' ]; then
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

bd_debug "BD_BAG_DIRS = ${BD_BAG_DIRS[@]}"

#
# 6 - update environment aliases
#

bd_aliases

#
# 7 - autoload all bagged directories
#

bd_load "${BD_BAG_DIRS[@]}"

export BD_ID BD_HOME BD_UPDATE_URL BD_VERSION

#
# metadata
#

# vim:ts=4:sw=4
# bash.d: imports BASH_SOURCE BD_DEBUG BD_ID
# bash.d: exports BD_ID BD_HOME BD_UPDATE_URL BD_VERSION
