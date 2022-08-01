#!/usr/bin/env bash

function elog_usage() {
    printf "usage: $0 [-h|d|q|s|t] [emer|alert|crit|error|warn|notice|info|debug] [log_message]\n\n"

    printf "Options:\n"
    printf "\t-h|--help           Print this Help\n"
    printf "\t-d|--debug          Enable Debug\n"
    printf "\t-q|--quiet          Don't print line header\n"
    printf "\t-s|--stacktrace     Enable Stacktrace\n"
    printf "\t-t|--time           Enable Date/Time Stamp\n"

    exit 1
}

function elog() {
    if [ $# -lt 2 ]; then
        elog_usage
    fi

    elog_levels=(emer alert crit error warn notice info debug)
    
    # Set the color codes
    if tput setaf 1 &>/dev/null; then
        reset=$(tput sgr0)
        black=$(tput setaf 0)
        red=$(tput setaf 1)
        green=$(tput setaf 2)
        yellow=$(tput setaf 3)
        blue=$(tput setaf 4)
        cyan=$(tput setaf 6)
        orange=$(tput setaf 166)
        purple=$(tput setaf 125)
        violet=$(tput setaf 61)
        white=$(tput setaf 7)
    else
        reset="\[\e[0m\]"
        black="\[\e[1;30m\]"
        red="\[\e[1;31m\]"
        green="\[\e[1;32m\]"
        yellow="\[\e[1;33m\]"
        blue="\[\e[1;34m\]"
        cyan="\[\e[1;36m\]"
        orange="\[\e[1;33m\]"
        purple="\[\e[1;35m\]"
        violet="\[\e[1;35m\]"
        white="\[\e[1;37m\]"
    fi

    # Parse args
    while :; do
        if [[ $# -eq 0 ]]; then
            break
        elif [[ $1 =~ ^- ]]; then
            case $1 in
                -d|--debug)         debug=0                                     ;;
                -h|--help)          elog_usage                                  ;;
                -q|--quiet)         quiet=0                                     ;;
                -s|--stacktrace)    stacktrace=0                                ;;
                -t|--time)          timestamp="$(date '+%Y/%m/%d %H:%M:%S') "   ;;
                *)                  elog_usage                                  ;;
            esac
            shift
        else
            log_level=$(echo ${1} | awk '{print tolower($0)}')
            case ${log_level} in
                emer)  # Level 0
                    color=${red}  ;;
                alert)  # Level 1
                    color=${orange}  ;;
                crit)  # Level 2
                    color=${violet}  ;;
                error)  # Level 3
                    color=${purple}  ;;
                warn)  # Level 4
                    color=${blue}  ;;
                notice)  # Level 5
                    color=${cyan}  ;;
                info)  # Level 6
                    color=${yellow}  ;;
                debug)  # Level 7
                    color=${green}  ;;
            esac
            msg=$2
            shift; shift
        fi
    done

    if [[  ! " ${elog_levels[*]} " =~ " ${log_level} " ]]; then
        elog_usage
    fi

    if [[ -z ${quiet} ]] || [[ ${quiet} -ne 0 ]]; then
        log_header="[$(echo $1 | awk '{print toupper($0)}')]: "
    fi

    printf "${color}${timestamp}${log_header}${msg}${reset}\n"

    # Print stacktrace if level is debug
    if [[ ${log_level} == "debug" ]]; then
        if [[ "${debug:-}" -ne 0 ]] &&  [[ "${stacktrace:-}" -ne 0 ]]; then
            BEGIN="${1:-1}"  # Display line numbers starting from given index, e.g. to skip "log::stacktrace" and "error" functions.
            for (( I=BEGIN; I<${#FUNCNAME[@]}; I++ )); do
                echo $'\t\t'"at ${FUNCNAME[$I]}(${BASH_SOURCE[$I]}:${BASH_LINENO[$I-1]})" >&2
            done
            echo
        fi
        unset I
        unset BEGIN
    fi
}

export -f elog_usage
export -f elog