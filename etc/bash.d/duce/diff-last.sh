# vim: ft=sh
# 2024.06.10 - ducet8@outlook.com
# Forked from: https://askubuntu.com/questions/229447/how-do-i-diff-the-output-of-two-commands

diff-last(){
    local diff_last_version='1.0.0-a'

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf 'diff-last'
            bd_ansi reset
            printf "\t${diff_last_version}\n"
            printf 'Diffs the output of two previously executed commands\n\n'
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\tdiff-last [OPTIONS]\n'
            bd_ansi fg_yellow3
            printf 'OPTIONS:\n'
            bd_ansi fg_blue1
            printf '\t-f|--first'
            bd_ansi reset
            printf '    The history number of the first command (Default: 1)\n'
            bd_ansi fg_blue1
            printf '\t-l|--last'
            bd_ansi reset
            printf '     The history number of the last command (Default: 2)\n'
            bd_ansi fg_blue1
            printf '\t-h|--help'
            bd_ansi reset
            printf '     Displays this help message\n'
            bd_ansi reset
        else
            printf "diff-last\t${diff_last_version}\n"
            printf 'Diffs the output of two previously executed commands\n\n'
            printf 'USAGE:\n'
            printf '\tdiff-last [OPTIONS]\n'
            printf 'OPTIONS:\n'
            printf '\t-f|--first    The history number of the first command (Default: 1)\n'
            printf '\t-l|--last     The history number of the last command (Default: 2)\n'
            printf '\t-h|--help     Displays this help message\n'
        fi
    }

    # Process arguments
    while [ $# -gt 0 ]; do
        case "${1}" in
            -f|--first)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    local first="${1%/}"
                    shift
                else
                    echo 'Error: -f flag requires a history number argument.'
                    return 1
                fi
                ;;
            -l|--last)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    local last="${1%/}"
                    shift
                else
                    echo 'Error: -l flag requires a history number argument.'
                    return 1
                fi
                ;;
            -h|--help)
                print_help
                return 0
                ;;
            *)
                echo 'Invalid option' && echo
                print_help
                return 1
                ;;
        esac
    done

    # Checks
    if [ -z ${first} ]; then
        local first="1"
    fi

    if [ -z ${last} ]; then
        local last="2"
    fi

    # Main
    # The fc flags are:
    #   -n: No number - suppresses the command numbers when listing
    #   -l: Listing - commands are listed on standard output
    # The arguments '-1 -1' refer to the start and end position in the history. In this case its from the last command to the last command which yields just the last command.
    diff --color <( $(fc -ln "-$first" "-$first") ) <( $(fc -ln "-$last" "-$last") )
}
