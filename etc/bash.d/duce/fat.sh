# vim: ft=sh
# 2023.11.01 - ducet8@outlook.com

# Read exported functions and pipe them through bat, if available
fat() {
    local version='1.0.0-a'

    print_help() {
        local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')
        local description="Read the exported function through bat or cat"
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "${program}"
            bd_ansi reset
            printf "\t${version}\n"
            printf "${description}\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t${program} <function>\n"
            bd_ansi fg_yellow3
            printf "ARGUMENTS:\n"
            bd_ansi fg_blue1
            printf "\t<function>"
            bd_ansi reset
            printf "     The function to bat or cat\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "      Display this help\n"
        else
            printf "${program}\t${version}\n"
            printf "${description}\n\n"
            printf "USAGE:\n"
            printf "\t${program} <function>\n"
            printf "ARGUMENTS:\n"
            printf "\t<function>     The function to bat or cat\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help      Display this help\n"
        fi
    }

    [ $# -ne 1 ] && print_help && return 1

    if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
        print_help
        return 0
    fi

    if type -P bat &>/dev/null; then
        typeset -f ${1} | bat -l sh --paging=never --theme="gruvbox-dark"
    else
        typeset -f ${1}
    fi
}
