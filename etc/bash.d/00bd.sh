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

export BD_VERSION=0.40.2

# prevent non-bash bourne compatible shells
[ "${BASH_SOURCE}" == '' ] && return &> /dev/null

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
    bd_debug "function ${FUNCNAME}(${@})" 55

    [ ${#BD_BASH_INIT_FILE} -gt 0 ] && [ -r "${BD_BASH_INIT_FILE}" ] && alias bd="source '${BD_BASH_INIT_FILE}'"

    if ! type -P bd-ansi &> /dev/null; then
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
    fi

    if ! type -P bd-debug &> /dev/null; then
        if [ -r "${BD_DIR}/bin/bd-debug" ]; then
            [ ! -x "${BD_DIR}/bin/bd-debug" ] && chmod u+x "${BD_DIR}/bin/bd-debug"
            alias bd-debug="${BD_DIR}/bin/bd-debug"
        else
            alias bd-debug=false
        fi
    fi
}

# stub bd_ansi until bd-ansi.sh is loaded (for embedded bd_debug)
if ! type -t bd_ansi &> /dev/null; then
    function bd_ansi() {
        return
    }
fi

# call bd_autoloader on an array (of directories)
function bd_autoload() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    [ ${#1} -eq 0 ] && return 1

    local bd_autoload_bag_dir bd_autoload_finish bd_autoload_start bd_autoload_total bd_autoload_total_ms

    for bd_autoload_bag_dir in "${@}"; do
        [ ${#BD_DEBUG} -gt 0 ] && bd_autoload_start=$(bd_uptime)

        bd_autoloader "${bd_autoload_bag_dir}"

        if [ ${#BD_DEBUG} -gt 0 ]; then
            bd_autoload_finish=$(bd_uptime)
            bd_autoload_total=$((${bd_autoload_finish}-${bd_autoload_start}))
            bd_autoload_total_ms="$(bd_debug_ms ${bd_autoload_total})"
            bd_debug "bd_autoloader ${bd_autoload_bag_dir} ${bd_autoload_total_ms}"
        fi
    done
    unset -v bd_autoload_bag_dir bd_autoload_finish bd_autoload_start bd_autoload_total bd_autoload_total_ms
}

# source everything in a given directory (that ends in .sh)
function bd_autoloader() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_autoloader_dir_name="${1}"

    if [ -d "${bd_autoloader_dir_name}" ]; then
        local bd_autoloader_file bd_autoloader_file_realpath

        local bd_autoloader_files=()

        # LC_COLLATE consistency hack (due to bsd/darwin differences)
        # https://blog.zhimingwang.org/macos-lc_collate-hunt
        # https://collation-charts.org/fbsd54/

        local bd_autoloader_lc_collate="${LC_COLLATE}"

        LC_COLLATE=POSIX # required for consistent collation across operating systems
        for bd_autoloader_file in "${bd_autoloader_dir_name}"/*\.{bash,sh}; do
            bd_autoloader_files+=("${bd_autoloader_file}")
        done
        unset -v bd_autoloader_file

        [ ${#bd_autoloader_lc_collate} -gt 0 ] && LC_COLLATE="${bd_autoloader_lc_collate}" || unset -v LC_COLLATE

        for bd_autoloader_file in "${bd_autoloader_files[@]}"; do

            # don't source itself ...
            [ "${bd_autoloader_file}" == "${BD_SOURCE}" ] && bd_debug "${FUNCNAME} ${bd_autoloader_file} matches relative path" 13 && continue # relative location
            [ "${bd_autoloader_file}" == "${BD_SOURCE##*/}" ] && bd_debug "${FUNCNAME}) ${bd_autoloader_file} matches basename" 13 && continue # basename

            if [ -r "${bd_autoloader_file}" ]; then
                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_autoloader_source_start
                    bd_autoloader_source_start=$(bd_uptime)
                fi

                bd_debug "source  ${bd_autoloader_file} ..." 4

                source "${bd_autoloader_file}" '' # pass an empty arg to ${1}

                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_autoloader_source_finish bd_autoloader_source_total bd_autoloader_source_total_ms
                    bd_autoloader_source_finish=$(bd_uptime)
                    bd_autoloader_source_total=$((${bd_autoloader_source_finish}-${bd_autoloader_source_start}))
                    bd_autoloader_source_total_ms=$(bd_debug_ms ${bd_autoloader_source_total})
                    bd_debug "source ${bd_autoloader_file} ${bd_autoloader_source_total_ms}" 3
                fi
            fi
        done
        unset -v bd_autoloader_file bd_autoloader_files
    fi
}

# add a specific subdirectory via bd_bagger; a single 'bag' is simply a subdirectory in ${BD_PATH}
function bd_bag() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_bag_name="${1}"

    local bd_bag_dir_name bd_bag_dir_names

    bd_bag_dir_names=()

    [ "${bd_bag_name}" == 'bash.d' ] && bd_bag_dir_names+=("${BD_DIR}/${bd_bag_name}")

    bd_bag_dir_names+=("/${BD_BAG_DEFAULT_DIR}/${bd_bag_name}")

    [ "${BD_HOME}" != "${HOME}" ] && bd_bag_dir_names+=("${BD_HOME}/${BD_BAG_DEFAULT_DIR}/${bd_bag_name}")
    [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ] && bd_bag_dir_names+=("${HOME}/${BD_BAG_DEFAULT_DIR}/${bd_bag_name}")

    for bd_bag_dir_name in ${bd_bag_dir_names[@]}; do
        bd_bag_dir_name=${bd_bag_dir_name//\/\//\/}
        bd_debug "1 bd_bag_dir_name = ${bd_bag_dir_name} [bag]" 6

        bd_bag_dir_name="$(bd_realpath "${bd_bag_dir_name}")"
        bd_debug "2 bd_bag_dir_name = ${bd_bag_dir_name} [bag]" 6

        bd_bagger "${bd_bag_dir_name}"
    done

    unset -v bd_bag_dir_name
}

# add unique, existing directories to the global BD_BAG_DIRS array (& preserve the natural order)
function bd_bagger() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_bagger_dir_name="${1//\/\//\/}"

    bd_bagger_dir_name="${bd_bagger_dir_name//\/\//\/}"
    bd_bagger_dir_name="${bd_bagger_dir_name//\/\//\/}"

    bd_debug "1 bd_bagger_dir_name = ${bd_bagger_dir_name}" 6

    [ ${#bd_bagger_dir_name} -eq 0 ] && return 1

    [ ! -d "${bd_bagger_dir_name}" ] && return 1

    bd_bagger_dir_name="$(bd_realpath "${bd_bagger_dir_name}")"

    bd_debug "2 bd_bagger_dir_name = ${bd_bagger_dir_name}" 6

    [ ${#BD_BAG_DIRS} -eq 0 ] && BD_BAG_DIRS=()

    local bd_bagger_bag_dir_exists=0 # false

    local bd_bagger_bag_dir
    for bd_bagger_bag_dir in ${BD_BAG_DIRS[@]}; do
        [ ${bd_bagger_bag_dir_exists} -eq 1 ] && break
        [ "${bd_bagger_bag_dir}" == "${bd_bagger_dir_name}" ] && bd_bagger_bag_dir_exists=1
    done
    unset -v bd_bagger_bag_dir

    [ ${bd_bagger_bag_dir_exists} -eq 0 ] && BD_BAG_DIRS+=("${bd_bagger_dir_name}") && bd_debug "bd_bagger_dir_name = ${bd_bagger_dir_name}" 2

    unset -v bd_bagger_bag_dir_exists
}

# add BD_BAG_DIR to BD_BAG_DIRS
function bd_config_bag_dirs() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_config_bag_dir_name="${1}"

    bd_debug "bd_config_bag_dir_name = ${bd_config_bag_dir_name}" 4

    if [ ${#BD_CONFIG_BAG_DIRS} -gt 0 ]; then
        local bd_config_bag_dir
        for bd_config_bag_dir in "${BD_CONFIG_BAG_DIRS[@]}"; do
            if [ "${bd_config_bag_dir:0:1}" == "/" ]; then
                # fully qualified path
                [ -d "${bd_config_bag_dir}" ] && [ -r "${bd_config_bag_dir}" ] && bd_bagger "${bd_config_bag_dir}"
            else
                # relative path
                [ -d "${bd_config_bag_dir_name}/${bd_config_bag_dir}" ] && [ -r "${bd_config_bag_dir_name}/${bd_config_bag_dir}" ] && bd_bagger "${bd_config_bag_dir_name}/${bd_config_bag_dir}"
            fi
        done
        unset -v bd_config_bag_dir
    fi
    unset -v BD_CONFIG_BAG_DIRS

}

# export BD_ environment variables from config file
function bd_config_file() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_config_file_name="${1}"
    local bd_config_file_preload="${2}"

    if [ -r "${bd_config_file_name}" ]; then
        bd_debug "bd_config_file_name=${bd_config_file_name} ${bd_config_file_preload}"

        local bd_config_file_line bd_config_file_variable_name bd_config_file_variable_value
        while read -r bd_config_file_line; do
            # only BD_* variables are supported
            [[ "${bd_config_file_line}" != 'BD_'* ]] && continue

            # these will break bd & are not supported in config files
            [[ "${bd_config_file_line}" == 'BD_DIR'* ]] && continue

            bd_debug "bd_config_file_line=${bd_config_file_line}" 20

            bd_config_file_variable_name="${bd_config_file_line%%=*}"

            bd_debug "bd_config_file_variable_name=${bd_config_file_variable_name}" 4

            bd_config_file_variable_value="${bd_config_file_line#*=}"
            bd_config_file_variable_value="${bd_config_file_variable_value%%'#'*}" # remove trailing comments
            bd_config_file_variable_value="${bd_config_file_variable_value%"${bd_config_file_variable_value##*[![:space:]]}"}" # remove trailing spaces
            bd_config_file_variable_value="${bd_config_file_variable_value%\"*}" # remove opening "
            bd_config_file_variable_value="${bd_config_file_variable_value#\"*}" # remove closing "
            bd_config_file_variable_value="${bd_config_file_variable_value%\'*}" # remove opening '
            bd_config_file_variable_value="${bd_config_file_variable_value#\'*}" # remove closing '

            bd_debug "bd_config_file_variable_value=${bd_config_file_variable_value}" 11

            if [ "${bd_config_file_variable_name}" == 'BD_BAG_DIR' ]; then
                [ "${bd_config_file_preload}" == "preload" ] && continue
                bd_debug "export BD_CONFIG_BAG_DIRS+=(\"${bd_config_file_variable_value}\")" 15
                export BD_CONFIG_BAG_DIRS+=("${bd_config_file_variable_value}")
            else
                [ "${bd_config_file_preload}" != "preload" ] && continue
                bd_debug "export ${bd_config_file_variable_name}=\"${bd_config_file_variable_value}\"" 15
                export ${bd_config_file_variable_name}="${bd_config_file_variable_value}"
            fi
        done < "${bd_config_file_name}"
        unset -v bd_config_file_line bd_config_file_variable_name bd_config_file_variable_value
    else
        return 1
    fi
}

# formatted debug output
function bd_debug() {

    [ ${#BD_DEBUG} -eq 0 ] && return 0

    [ ${#1} -eq 0 ] && return 0

    [[ ! "${BD_DEBUG}" =~ ^[0-9]+$ ]] && BD_DEBUG=0

    [ "${BD_DEBUG}" == '0' ] && return 0

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

        local bd_debug_bash_source=''
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

        type bd_ansi &> /dev/null && printf "$(bd_ansi reset)$(bd_ansi fg${bd_debug_color})"
        printf "[BD_DEBUG:%+2b:%b] [%b] %b" "${bd_debug_level}" "${BD_DEBUG}" "${bd_debug_bash_source}" "${bd_debug_msg}" 1>&2
        type bd_ansi &> /dev/null && printf "$(bd_ansi reset)"
        printf "\n"
    fi

    return 0
}
export -f bd_debug

# colored debug output for milliseconds
function bd_debug_ms() {

    [ ${#1} -eq 0 ] && return 0

    [ ${#BD_DEBUG} -eq 0 ] && return 0

    [ "${BD_DEBUG}" == '0' ] && return 0

    local bd_debug_ms_int=${1} bd_debug_ms_msg

    [[ ! "${bd_debug_ms_int}" =~ ^[0-9]+$ ]] && return

    [ ${bd_debug_ms_int} -le 100 ] && bd_debug_ms_msg="$(bd_ansi fg_green1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 100 ] && bd_debug_ms_msg="$(bd_ansi fg_magenta1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 499 ] && bd_debug_ms_msg="$(bd_ansi fg_yellow1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 999 ] && bd_debug_ms_msg="$(bd_ansi fg_red1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"

    printf "${bd_debug_ms_msg}" # use as subshell; does not output to stderr

    return 0
}
export -f bd_debug_ms

# semi-portable readlink/realpath
function bd_realpath() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_realpath_arg="${1}"

    [ ${#bd_realpath_arg} -eq 0 ] && return 1

    local bd_realpath_basename bd_realpath_dirname bd_realpath_name

    if [ -r "${bd_realpath_arg}" ]; then
        if [ -d "${bd_realpath_arg}" ]; then
            bd_realpath_name="$(cd "${bd_realpath_arg}" &> /dev/null; pwd -P)"
        else
            bd_realpath_dirname="${bd_realpath_arg%/*}"
            if [ -d "${bd_realpath_dirname}" ]; then
                bd_realpath_basename="${bd_realpath_arg##*/}"
                bd_realpath_name="$(cd "${bd_realpath_dirname}" &> /dev/null; pwd -P)"
                bd_realpath_name+="/${bd_realpath_basename}"
            fi
        fi
    fi

    printf "${bd_realpath_name}"
}

# unset & re-source system profile
function bd_start() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    unset -v BD_ID

    if shopt -q login_shell; then
        [ -r "/etc/profile" ] && unset -v BASHRCSOURCED && source /etc/profile
    else
        [ -r "/etc/bashrc" ] && unset -v BASHRCSOURCED && source /etc/bashrc
    fi
}

# return 0 if 1, true, or yes
function bd_true() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    if [ "${1}" == '1' ] || [ "${1}" == 'true' ] || [ "${1}" == 'yes' ]; then
        return 0
    else
        return 1
    fi
}

# unset functions & variables
function bd_unset() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_unset_start="${1}"

    local bd_unset_alias_name bd_unset_alias_names=()
    local bd_unset_function_name bd_unset_function_names=()
    local bd_unset_variable_name bd_unset_variable_names=()

    if [ "${bd_unset_start}" == 'start' ]; then
        # start

        # aliases
        bd_unset_alias_names+=(bd)
        bd_unset_alias_names+=(bd-ansi)
        bd_unset_alias_names+=(bd-debug)

        for bd_unset_alias_name in ${bd_unset_alias_names[@]}; do
            alias "${bd_unset_alias_name}" &> /dev/null && unalias "${bd_unset_alias_name}"
        done
        unset -v bd_unset_alias_name

        # variables
        local bd_unset_variable bd_unset_variable_name bd_unset_oifs
        bd_unset_oifs="${IFS}"
        IFS=$'\n'
        for bd_unset_variable in $(declare -g 2> /dev/null); do
            if [[ "${bd_unset_variable}" == 'BD_'*'='* ]]; then
                bd_unset_variable_name="${bd_unset_variable%%=*}"

                # don't unset these
                [ "${bd_unset_variable_name}" == 'BD_BASH_INIT_FILE' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_DEBUG' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_HOME' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_ID' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_LEARN' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_MAIN' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_SOURCE' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_USER' ] && continue

                if [ "${bd_unset_variable_name}" == 'BD_BAG_DIRS' ]; then
                    if bd_true ${BD_LEARN}; then
                        bd_unset_variable_names+=("${bd_unset_variable_name}")
                    fi
                else
                    bd_unset_variable_names+=("${bd_unset_variable_name}")
                fi
            fi
        done
        IFS="${bd_unset_oifs}"
        unset -v bd_unset_variable bd_unset_variable_name bd_unset_oifs
    else
        # finish

        # functions
        bd_unset_function_names+=(bd_aliases)
        bd_unset_function_names+=(bd_ansi_chart)
        bd_unset_function_names+=(bd_ansi_chart_16)
        bd_unset_function_names+=(bd_ansi_chart_16_bg)
        bd_unset_function_names+=(bd_ansi_chart_16_fg)
        bd_unset_function_names+=(bd_ansi_chart_256)
        bd_unset_function_names+=(bd_ansi_chart_256_bg)
        bd_unset_function_names+=(bd_ansi_chart_256_fg)
        bd_unset_function_names+=(bd_autoload)
        bd_unset_function_names+=(bd_autoloader)
        bd_unset_function_names+=(bd_bag)
        bd_unset_function_names+=(bd_bagger)
        bd_unset_function_names+=(bd_config_bag_dirs)
        bd_unset_function_names+=(bd_config_file)
        bd_unset_function_names+=(bd_realpath)
        bd_unset_function_names+=(bd_start)
        bd_unset_function_names+=(bd_upgrade)
        bd_unset_function_names+=(bd_uptime)

        for bd_unset_function_name in ${bd_unset_function_names[@]}; do
            unset -f "${bd_unset_function_name}"
        done
        unset -v bd_unset_function_name

        # variables
        bd_unset_variable_names+=(BD_BAG_DEFAULT_DIR)
        bd_unset_variable_names+=(BD_CONFIG_FILE)
        bd_unset_variable_names+=(BD_MAIN)

    fi

    for bd_unset_variable_name in ${bd_unset_variable_names[@]}; do
        bd_debug "unset -v ${bd_unset_variable_name}" 5
        unset -v ${bd_unset_variable_name}
    done
    unset -v bd_unset_variable_name

    if [ "${bd_unset_start}" != 'start' ]; then
        # finish

        if bd_true ${BD_ANSI_EXPORT}; then
            export -f bd_ansi
        else
            unset -f bd_ansi
        fi

        if bd_true ${BD_DEBUG_EXPORT}; then
            export -f bd_debug bd_debug_ms
        else
            unset -f bd_debug bd_debug_ms
        fi

        unset -f bd_true bd_unset
    fi

    unset -v bd_unset_alias_name bd_unset_alias_names
    unset -v bd_unset_function_name bd_unset_function_names
    unset -v bd_unset_variable_name bd_unset_variable_names
}

# upgrade to the latest version of 00bd.sh (WIP)
function bd_upgrade() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_upgrade_dir_name="${1}"

    if type -P git &> /dev/null; then
        if [ -d "${bd_upgrade_dir_name}" ]; then
            local bd_upgrade_pwd="${PWD}"

            cd "${bd_upgrade_dir_name}"

            if [ -d .git ]; then
                git remote -v && echo && git pull && echo
            fi

            cd "${bd_upgrade_pwd}"

            unset -v bd_upgrade_pwd
        fi
    else
        echo; echo 'git not found'; echo
    fi
}

# output milliseconds since uptime (used for debugging)
function bd_uptime() {
    bd_debug "function ${FUNCNAME}(${@})" 55

    local bd_uptime_ms bd_uptime_t1
    if [ ${BASH_VERSINFO[0]} -ge 5 ]; then
        bd_uptime_t1=${EPOCHREALTIME//.}
        bd_uptime_ms=$((${bd_uptime_t1}/1000))
    else
        local bd_uptime_t0
        if [ "${BD_OS}" == 'linux' ] || [ "${BD_OS}" == 'windows' ] || [ "${BD_OS}" == 'wsl' ]; then
            local bd_uptime_idle
            # linux & windows; use /proc/uptime
            read bd_uptime_t0 bd_uptime_idle < /proc/uptime
            bd_uptime_t1="${bd_uptime_t0//.}"
            bd_uptime_ms=$((${bd_uptime_t1}*10))
        fi

        if [ "${BD_OS}" == 'darwin' ]; then
            # bsd & darwin; use sysctl
            bd_uptime_t0="$(sysctl -n kern.boottime 2> /dev/null)"
            bd_uptime_t1="${bd_uptime_t0%,*}"
            bd_uptime_t1="${bd_uptime_t1##* }"
            bd_uptime_ms=$((($(date +%s)-${bd_uptime_t1})*1000))
        fi
    fi

    printf "${bd_uptime_ms}"
}

#
# boot
#

export BD_DEBUG=${BD_DEBUG:-0} # level >0 enables debugging

export BD_SOURCE="$(bd_realpath "${BASH_SOURCE}")"

#
# arguments
#

# dir/dirs arguments
if [ "${1}" == 'dir' ] || [ "${1}" == 'dirs' ]; then
    echo "${BD_BAG_DIRS[@]}"

    return 0
fi

# env argument
if [ "${1}" == 'env' ]; then
    bd_debug "${BD_SOURCE} env" 1

    BD_OIFS="${IFS}"
    IFS=$'\n'
    for BD_DECLARE in $(declare -g 2> /dev/null); do
        if [[ "${BD_DECLARE}" == 'BD_'*'='* ]]; then
            BD_VARIABLE_NAME="${BD_DECLARE%%=*}"
            [ "${BD_VARIABLE_NAME}" == 'BD_DECLARE' ] && continue
            [ "${BD_VARIABLE_NAME}" == 'BD_OIFS' ] && continue
            [ "${BD_VARIABLE_NAME}" == 'BD_VARIABLE_NAME' ] && continue
            printf "%-30s" "${BD_VARIABLE_NAME}"
            printf " = "
            if [ "${BD_VARIABLE_NAME}" == 'BD_BAG_DIRS' ]; then
                echo "${BD_BAG_DIRS[@]}"
            else
                echo "${!BD_VARIABLE_NAME}"
            fi
        fi
    done
    IFS="${BD_OIFS}"
    unset -v BD_DECLARE BD_OIFS BD_VARIABLE_NAME

    return $?
fi

# functions argument
if [ "${1}" == 'functions' ]; then
    return $?
fi

# license argument
if [ "${1}" == 'license' ]; then
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

# pull/update/upgrade arguments
if [ "${1}" == 'pull' ] || [ "${1}" == 'update' ] || [ "${1}" == 'upgrade' ]; then
    bd_debug "${BD_SOURCE} upgrade" 1

    [ ! -O "${BD_SOURCE}" ] && printf "\nrun 'bd ${1}' as the owner of ${BD_SOURCE} ...\n\n" && ls -l "${BD_SOURCE}" && echo && return 1

    bd_upgrade "${BD_DIR}"

    return $?
fi

# default/reload/restart/start arguments
if [ "${1}" == '' ] || [ "${1}" == 'reload' ] || [ "${1}" == 'restart' ] || [ "${1}" == 'start' ]; then
    bd_debug "${BD_SOURCE} reload" 1

    bd_start

    # do not return!
fi

#
# prevent main loading multiple times (i.e. due to recursive links, improper sourcing, etc)
#

[ ${#BD_ID} -gt 0 ] && return 0

#
# main
#

bd_debug "${BD_SOURCE} main started"

export BD_MAIN=1

#
# unset (most of the) included bd- aliases, bd_ functions, & BD_ variables
#

bd_unset start

#
# (re)set BD_ config variables (after bd_unset start)
#

BD_CONFIG_FILE='.bd.conf'

BD_BAG_DEFAULT_DIR='etc/bash.d'

export BD_DIR="${BD_SOURCE%/*}"

bd_debug "BD_DIR = ${BD_DIR}" 2
bd_debug "BD_SOURCE = ${BD_SOURCE}" 2

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

bd_debug "BD_ID = ${BD_ID}" 2

#
# preload config file (variables) - ${BD_DIR}
#

[ -f "${BD_DIR}/${BD_CONFIG_FILE}" ] && [ -r "${BD_DIR}/${BD_CONFIG_FILE}" ] && bd_config_file "${BD_DIR}/${BD_CONFIG_FILE}" preload

#
# preload config file (variables) - /${BD_BAG_DEFAULT_DIR}/.. (/etc)
#

[ ${#BD_BAG_DEFAULT_DIR} -gt 0 ] && [ "/${BD_BAG_DEFAULT_DIR}/.." != "//.." ] && [ -f "/etc/${BD_CONFIG_FILE/./}" ] && [ -r "/etc/${BD_CONFIG_FILE/./}" ] && bd_config_file "/etc/${BD_CONFIG_FILE/./}" preload

#
# preload config file (variables) - ${HOME}
#

[ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ] && [ -f "${HOME}/${BD_CONFIG_FILE}" ] && [ -r "${HOME}/${BD_CONFIG_FILE}" ] && bd_config_file "${HOME}/${BD_CONFIG_FILE}" preload

#
# preload config file (variables) - ${BD_HOME}
#

[ ${#BD_HOME} -gt 0 ] && [ "${BD_HOME}" != "/" ] && [ "${BD_HOME}" != "${HOME}" ] && [ -f "${BD_HOME}/${BD_CONFIG_FILE}" ] && [ -r "${BD_HOME}/${BD_CONFIG_FILE}" ] && bd_config_file "${BD_HOME}/${BD_CONFIG_FILE}" preload

#
# preload config file (variables) - ${PWD}
#

[ ${#PWD} -gt 0 ] && [ "${PWD}" != "/etc" ] && [ "${PWD}" != "${BD_HOME}" ] && [ "${PWD}" != "${HOME}" ] && [ -f "${PWD}/${BD_CONFIG_FILE}" ] && [ -r "${PWD}/${BD_CONFIG_FILE}" ] && bd_config_file "${PWD}/${BD_CONFIG_FILE}" && bd_config_bag_dirs "${PWD}"

#
# determine operating system; set BD_OS variables
#

BD_OS='unknown'

if type -P uname &> /dev/null; then
    BD_OS_KERNEL_NAME="$(uname -s 2> /dev/null)"

    if [ ${BASH_VERSINFO[0]} -ge 4 ]; then
        BD_OS_KERNEL_NAME=${BD_OS_KERNEL_NAME,,}
    else
        BD_OS_KERNEL_NAME="$(tr [A-Z] [a-z] <<< "${BD_OS_KERNEL_NAME}")" # posix (bash 3; [i.e. darwin])
    fi

    case "${BD_OS_KERNEL_NAME}" in
        bsd*)                           BD_OS='bsd';;
        darwin*)                        BD_OS='darwin';;
        linux*)                         BD_OS='linux';;
        solaris*)                       BD_OS='solaris';;
        cygwin*|mingw*|win*)            BD_OS='windows';;
        linux*microsoft*)               BD_OS='wsl';;
        *)                              BD_OS="unknown:${BD_OS_KERNEL_NAME}"
    esac

    unset -v BD_OS_KERNEL_NAME
fi

export BD_OS

bd_debug "BD_OS = ${BD_OS}" 1

if [ ${#BD_DEBUG} -gt 0 ]; then
    BD_START_TIME=$(bd_uptime)
fi

#
# ensure BD_BAG_DIRS, BD_BASH_INIT_FILE, BD_HOME, BD_USER, & USER; (WIP)
#

unset -v BD_CONFIG_BAG_DIRS

# TODO: learn requires more testing
bd_true ${BD_LEARN} && BD_BAG_DIRS=()

[ "${EUID}" == '0' ] && USER=root

[ "${USER}" != 'root' ] && unset BD_USER # honor sudo --preserve-env=BD_USER

# preferred order of sources for BD_USER
[ ${#BD_USER} -eq 0 ] && [ "${USER}" == 'root' ] && type -P logname &> /dev/null && BD_USER=$(logname 2> /dev/null) # hack; only use logname for root?
[ ${#BD_USER} -eq 0 ] && [ ${#USER} -gt 0 ] && BD_USER=${USER} # default to ${USER}
[ ${#BD_USER} -eq 0 ] && [ ${#USERNAME} -gt 0 ] && BD_USER=${USERNAME}
[ ${#BD_USER} -eq 0 ] && type -P who &> /dev/null && BD_USER=$(who -m 2> /dev/null)
[ ${#BD_USER} -eq 0 ] && [ ${#SUDO_USER} -gt 0 ] && BD_USER=${SUDO_USER}
[ ${#BD_USER} -eq 0 ] && [ ${#LOGNAME} -gt 0 ] && BD_USER=${LOGNAME}

[ ${#USER} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && USER=${BD_USER}

export BD_USER

[ "${USER}" != 'root' ] && unset BD_HOME # honor sudo --preserve-env=BD_HOME

[ ${#BD_USER} -eq 0 ] && BD_HOME="/tmp"

# preferred order of sources for BD_HOME
[ ${#BD_HOME} -eq 0 ] && [ ${#HOME} -gt 0 ] && BD_HOME=${HOME} # default to ${HOME}
[ ${#BD_HOME} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && type -P getent &> /dev/null && BD_HOME=$(getent passwd ${BD_USER} 2> /dev/null) && BD_HOME=${BD_HOME%%:*}
[ ${#BD_HOME} -eq 0 ] && BD_HOME="~"

export BD_HOME

if shopt -q login_shell; then
    # login shell
    [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bash_profile" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bash_profile"
    [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r ~/.bash_profile ] && BD_BASH_INIT_FILE=~/.bash_profile
fi

# not a login shell, or it is a login shell and there's no ~/.bash_profile
[ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bashrc" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bashrc"
[ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bash_profile" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bash_profile"

export BD_BASH_INIT_FILE

#
#  bd_bag included (bash.d) extensions
#

bd_bag 'bash.d'

[ -f "${BD_DIR}/${BD_CONFIG_FILE}" ] && [ -r "${BD_DIR}/${BD_CONFIG_FILE}" ] && bd_config_file "${BD_DIR}/${BD_CONFIG_FILE}" && bd_config_bag_dirs "${BD_DIR}"

#
# bd_bagger /${BD_BAG_DEFAULT_DIR}/.. (/etc)
#

if [ ${#BD_BAG_DEFAULT_DIR} -gt 0 ] && [ "/${BD_BAG_DEFAULT_DIR}/.." != "//.." ]; then
    bd_debug "BD_BAG_DEFAULT_DIR = /${BD_BAG_DEFAULT_DIR}/.." 4

    [ -f "/${BD_BAG_DEFAULT_DIR}/../${BD_CONFIG_FILE/./}" ] && [ -r "/${BD_BAG_DEFAULT_DIR}/../${BD_CONFIG_FILE/./}" ] && bd_config_file "/${BD_BAG_DEFAULT_DIR}/../${BD_CONFIG_FILE/./}" && bd_config_bag_dirs /

    if [ -d "/${BD_BAG_DEFAULT_DIR}" ] && [ -r "/${BD_BAG_DEFAULT_DIR}" ]; then
        bd_bagger "/${BD_BAG_DEFAULT_DIR}"

        for BD_BAGGER_DIR in "/${BD_BAG_DEFAULT_DIR}"/*; do
            [ -d "${BD_BAGGER_DIR}" ] && [ -r "${BD_BAGGER_DIR}" ] && bd_bagger "${BD_BAGGER_DIR}"
        done
        unset -v BD_BAGGER_DIR
    fi
fi

#
# bd_bagger ${HOME}
#

# HOME may or may not be set, e.g. su & sudo preserve environment, etc
if [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ]; then
    bd_debug "HOME = ${HOME}" 4

    [ -f "${HOME}/${BD_CONFIG_FILE}" ] && [ -r "${HOME}/${BD_CONFIG_FILE}" ] && bd_config_file "${HOME}/${BD_CONFIG_FILE}" && bd_config_bag_dirs "${HOME}"

    if [ -d "${HOME}/${BD_BAG_DEFAULT_DIR}" ] && [ -r "${HOME}/${BD_BAG_DEFAULT_DIR}" ]; then
        bd_bagger "${HOME}/${BD_BAG_DEFAULT_DIR}"

        for BD_BAGGER_DIR in "${HOME}/${BD_BAG_DEFAULT_DIR}"/*; do
            [ -d "${BD_BAGGER_DIR}" ] && [ -r "${BD_BAGGER_DIR}" ] && bd_bagger "${BD_BAGGER_DIR}"
        done
        unset -v BD_BAGGER_DIR
    fi
fi

#
# bd_bagger ${BD_HOME}
#

if [ ${#BD_HOME} -gt 0 ] && [ "${BD_HOME}" != "/" ] && [ "${BD_HOME}" != "${HOME}" ]; then
    bd_debug "BD_HOME = ${BD_HOME}" 4

    [ -f "${BD_HOME}/${BD_CONFIG_FILE}" ] && [ -r "${BD_HOME}/${BD_CONFIG_FILE}" ] && bd_config_file "${BD_HOME}/${BD_CONFIG_FILE}" && bd_config_bag_dirs "${BD_HOME}"

    if [ -d "${BD_HOME}/${BD_BAG_DEFAULT_DIR}" ] && [ -r "${BD_HOME}/${BD_BAG_DEFAULT_DIR}" ]; then
        bd_bagger "${BD_HOME}/${BD_BAG_DEFAULT_DIR}"

        for BD_BAGGER_DIR in "${BD_HOME}/${BD_BAG_DEFAULT_DIR}"/*; do
            [ -d "${BD_BAGGER_DIR}" ] && [ -r "${BD_BAGGER_DIR}" ] && bd_bagger "${BD_BAGGER_DIR}"
        done
        unset -v BD_BAGGER_DIR
    fi
fi

#
# bd_bagger ${PWD}
#

if [ ${#PWD} -gt 0 ] && [ "${PWD}" != "/etc" ] && [ "${PWD}" != "${BD_HOME}" ] && [ "${PWD}" != "${HOME}" ]; then
    bd_debug "PWD = ${PWD}" 4

    [ -f "${PWD}/${BD_CONFIG_FILE}" ] && [ -r "${PWD}/${BD_CONFIG_FILE}" ] && bd_config_file "${PWD}/${BD_CONFIG_FILE}" && bd_config_bag_dirs "${PWD}"

    if [ -d "${PWD}/${BD_BAG_DEFAULT_DIR}" ] && [ -r "${PWD}/${BD_BAG_DEFAULT_DIR}" ]; then
        bd_bagger "${PWD}/${BD_BAG_DEFAULT_DIR}"

        for BD_BAGGER_DIR in "${PWD}/${BD_BAG_DEFAULT_DIR}"/*; do
            [ -d "${BD_BAGGER_DIR}" ] && [ -r "${BD_BAGGER_DIR}" ] && bd_bagger "${BD_BAGGER_DIR}"
        done
        unset -v BD_BAGGER_DIR
    fi
fi

bd_debug "BD_BAG_DIRS = ${BD_BAG_DIRS[@]}" 1

#
# set environment aliases
#

bd_aliases

#
# autoload all bagged directories
#

bd_autoload "${BD_BAG_DIRS[@]}"

if [ ${#BD_DEBUG} -gt 0 ]; then
    BD_FINISH_TIME=$(bd_uptime)
    BD_TOTAL_TIME=$((${BD_FINISH_TIME}-${BD_START_TIME}))
    BD_TOTAL_TIME_MS="$(bd_debug_ms ${BD_TOTAL_TIME})"

    bd_debug "${BD_SOURCE} main finished ${BD_TOTAL_TIME_MS}" 0

    unset -v BD_FINISH_TIME BD_START_TIME BD_TOTAL_TIME BD_TOTAL_TIME_MS
fi

#
# unset ephemeral bd_ functions & BD_ variables
#

bd_unset finished
