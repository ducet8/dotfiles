# vim: ft=sh
# 2025.09.03 - ducet8@outlook.com

# Paragraph grep
pawk() {
    local version="1.1.0"

    print_help() {
        local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')
        local description="Print the paragraph containing the grepped result"
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf "%s\n\n" "${description}"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s [OPTIONS] <pattern> <file>\n" "${program}"
            bd_ansi fg_yellow3
            printf "ARGUMENTS:\n"
            bd_ansi fg_blue1
            printf "\t<pattern>"
            bd_ansi reset
            printf "           The pattern to grep\n"
            bd_ansi fg_blue1
            printf "\t<file>"
            bd_ansi reset
            printf "              The file to search\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-d|--debug"
            bd_ansi reset
            printf "          Debug - print the command\n"
            bd_ansi fg_blue1
            printf "\t-i|--insensitive"
            bd_ansi reset
            printf "    Case insensitive\n"
            bd_ansi fg_blue1
            printf "\t-v|--invert"
            bd_ansi reset
            printf "         Invert match (exclude pattern)\n"
            bd_ansi fg_blue1
            printf "\t-x|--no-bat"
            bd_ansi reset
            printf "         Disable bat parsing\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "           Display this help\n"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "%s\n\n" "${description}"
            printf "USAGE:\n"
            printf "\t%s [OPTIONS] <pattern> <file>\n" "${program}"
            printf "ARGUMENTS:\n"
            printf "\t<pattern>           The pattern to grep\n"
            printf "\t<file>              The file to search\n"
            printf "OPTIONS:\n"
            printf "\t-d|--debug          Debug - print the command\n"
            printf "\t-i|--insensitive    Case insensitive\n"
            printf "\t-v|--invert         Invert match (exclude pattern)\n"
            printf "\t-x|--no-bat         Disable bat parsing\n"
            printf "\t-h|--help           Display this help\n"
        fi
    }

    [ $# -lt 2 ] && print_help && return 1

    # Parse args
    while :; do
        if [[ $# -eq 0 ]]; then
            break
        elif [[ $1 =~ ^- ]]; then
            case $1 in
                -d|--debug)            local pawk_debug=1                                                 ;;
                -h|--help)             print_help && return 0                                             ;;
                -i|--insensitive)      local pawk_case_insensitive=1                                      ;;
                -v|--invert)           local pawk_exclude=1                                               ;;
                -x|--no-bat)           local skip_bat=1                                                   ;;
                *)                     echo 'Error: Invalid option' && echo && print_help && return 1     ;;
            esac
            shift
        else
            if [[ -z "${pattern:-}" ]]; then
                local pattern="$1"
                shift
            elif [[ -z "${file:-}" ]]; then
                local file="$1"
                shift
            else
                break
            fi
        fi
    done

    local section="'"
    if [[ -n "${pawk_case_insensitive}" ]]; then
        pattern=$(echo "${pattern}" | awk '{print tolower($0)}')
        section+='tolower($0)'
        if [[ -n "${pawk_exclude}" ]]; then
            section+='!~'
        else
            section+='~'
        fi
    elif [[ -n "${pawk_exclude}" ]]; then
        section+='!'
    fi
    section+="/$pattern/'"

    if type -P bat &>/dev/null; then
        if [[ -z "${skip_bat}" ]]; then
            local bat_lang="${file##*.}"
            if [[ -n "${bat_lang}" && "${bat_lang}" != "${file}" ]]; then
                local bat_addon="| bat -l ${bat_lang}"
            else
                local bat_addon="| bat"
            fi
        fi
    fi
    local pawk_cmd="awk ${section} RS='\\n\\n' ORS='\\n\\n' '${file}' ${bat_addon}"
    if [[ -n "${pawk_debug}" ]]; then
        printf "Running: %s\n" "${pawk_cmd}"
    fi
    eval "${pawk_cmd}"
}
