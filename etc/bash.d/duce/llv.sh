# vim: ft=sh
# 2025.09.03 - ducet8@outlook.com

# ls version sort with colors
llv() {
    local version="1.0.1"
    
    print_help() {
        local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf "List files with version-aware sorting and colors\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s [ls options] [path...]\n" "${program}"
            bd_ansi fg_yellow3
            printf "DESCRIPTION:\n"
            bd_ansi reset
            printf "\tCombines 'ls -lFha' with version-aware sorting (-V)\n"
            printf "\tAutomatically enables colors when available\n\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s\t\t\tList current directory\n" "${program}"
            printf "\t%s /usr/bin\t\tList /usr/bin directory\n" "${program}"
            printf "\t%s -t\t\t\tSort by time instead of name\n" "${program}"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "List files with version-aware sorting and colors\n\n"
            printf "USAGE:\n"
            printf "\t%s [ls options] [path...]\n" "${program}"
            printf "DESCRIPTION:\n"
            printf "\tCombines 'ls -lFha' with version-aware sorting (-V)\n"
            printf "\tAutomatically enables colors when available\n\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "EXAMPLES:\n"
            printf "\t%s\t\t\tList current directory\n" "${program}"
            printf "\t%s /usr/bin\t\tList /usr/bin directory\n" "${program}"
            printf "\t%s -t\t\t\tSort by time instead of name\n" "${program}"
        fi
    }
    
    abort_with_message() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_red1
            printf "\n✗ %s\n\n" "$*"
            bd_ansi reset
        else
            printf "\n✗ %s\n\n" "$*"
        fi
        return 1
    }
    
    # Handle help flags
    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
    esac
    
    # Run ls with color support and version sorting
    # Default to showing colors unless explicitly disabled
    if [[ ${NO_COLOR:-} == "1" ]]; then
        # Colors explicitly disabled
        ls -lFha "${@}" | sort -k 9 -V
    elif [[ ${BD_OS,,} == "darwin" ]]; then
        # macOS: Use CLICOLOR variables just for this command
        env CLICOLOR_FORCE=1 CLICOLOR=1 ls -lFha "${@}" | sort -k 9 -V
    else
        # Linux uses --color flag
        ls -lFha --color=always "${@}" | sort -k 9 -V
    fi
}
