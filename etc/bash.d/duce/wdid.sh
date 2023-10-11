# vim: ft=sh
# 2023.10.11 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

wdid() {
    local wdid_version="1.0.0-a"
    local accomplishments="${HOME}/Documents/daily_accomplishments.md"

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "wdid"
            bd_ansi reset
            printf "\t${wdid_version}\n"
            printf "Read and print daily accomplishments from ${accomplishments}\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\twdid [OPTIONS]\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-a|--all"
            bd_ansi reset
            printf "      Print the whole file\n"
            bd_ansi fg_blue1
            printf "\t-p|--previous"
            bd_ansi reset
            printf " Print the previous logged day's list\n"
            bd_ansi fg_blue1
            printf "\t-c|--current"
            bd_ansi reset
            printf "  Print the current day's list\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "     Displays this help\n"
            bd_ansi reset
        else
            printf "wdid\t${wdid_version}\n"
            printf "Read and print daily accomplishments from ${accomplishments}\n\n"
            printf "USAGE:\n"
            printf "\twdid [OPTIONS]\n"
            printf "OPTIONS:\n"
            printf "\t-a|--all      Print the whole file\n"
            printf "\t-p|--previous Print the previous logged day's list\n"
            printf "\t-c|--current  Print the current day's list\n"
            printf "\t-h|--help     Show this help message and exit\n"
        fi
    }

    if [ ! -e "${accomplishments}" ]; then
        echo "The file {$accomplishments} does not exist. Use 'did' to add daily accomplishments."
        return 1
    fi

    case "${1}" in
        -a|--all)
            cat "${accomplishments}"
            ;;
        -p|--previous)
            local today=$(date '+%Y-%m-%d')
            local yesterday=$(date -d "${today} - 1 day" '+%Y-%m-%d' 2>>/dev/null || date -j -v -1d -f "%Y-%m-%d" "${today}" '+%Y-%m-%d')
            sed -n "/## ${yesterday}/,/## ${today}/ p" "${accomplishments}"
            ;;
        -c|--current)
            local today=$(date '+%Y-%m-%d')
            sed -n "/## ${today}/,/## $(date -d "${today} + 1 day" '+%Y-%m-%d' 2>>/dev/null || date -j -v -1d -f "%Y-%m-%d" "${today}" '+%Y-%m-%d')/ p" "${accomplishments}"
            ;;
        -h|--help)
            print_help
            ;;
        *)
            echo "Invalid option" && echo
            print_help
            return 1
            ;;
    esac
}
