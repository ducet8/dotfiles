# vim: ft=sh
# 2024.06.03 - ducet8@outlook.com

hog(){
    local hog_version='1.0.0-a'

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf 'hog'
            bd_ansi reset
            printf "\t${hog_version}\n"
            printf 'Finds the disk hogs\n\n'
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\thog [OPTIONS]\n'
            bd_ansi fg_yellow3
            printf 'OPTIONS:\n'
            bd_ansi fg_blue1
            printf '\t-d|--dir'
            bd_ansi reset
            printf '        Directory to search (Default: cwd)\n'
            bd_ansi fg_blue1
            printf '\t-m|--max-depth'
            bd_ansi reset
            printf '  Depth to search (Default: 1)\n'
            bd_ansi fg_blue1
            printf '\t-h|--help'
            bd_ansi reset
            printf '       Displays this help message\n'
            bd_ansi reset
        else
            printf "hog\t${hog_version}\n"
            printf 'Finds the disk hogs\n\n'
            printf 'USAGE:\n'
            printf '\thog [OPTIONS]\n'
            printf 'OPTIONS:\n'
            printf '\t-d|--dir        Directory to search (Default: cwd)\n'
            printf '\t-m|--max-depth  Depth to search (Default: 1)\n'
            printf '\t-h|--help       Displays this help message\n'
        fi
    }

    # Process arguments
    while [ $# -gt 0 ]; do
        case "${1}" in
            -d|--dir)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    local dir="${1%/}"
                    shift
                else
                    echo 'Error: -d flag requires a directory argument.'
                    return 1
                fi
                ;;
            -m|--max-depth)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    local depth="${1%/}"
                    shift
                else
                    echo 'Error: -m flag requires a max-depth argument.'
                    return 1
                fi
                ;;
            -h|--help)
                print_help
                shift
                ;;
            *)
                echo 'Invalid option' && echo
                print_help
                return 1
                ;;
        esac
    done

    # Checks
    if [ -z ${dir} ]; then
        local dir="$(pwd)"
    fi

    if [ -z ${depth} ]; then
        local depth=1
    fi

    if [ ! -e "${dir}" ]; then
        echo "The directory ${dir} does not exist."
        return 1
    fi

    # Main
    if [[ ${BD_OS,,} == "darwin" ]]; then
        du -chd${depth} ${dir} | grep -E "M|G"
    else
        du -cha --max-depth=${depth} ${dir} | grep -E "M|G"
    fi
}
