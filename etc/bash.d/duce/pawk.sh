# 2023.01.25 - ducet8@outlook.com

# Paragraph grep

function pawk_usage() {
    printf "usage: $0 [-hvi] [pattern] [file]\n\n"
    
    printf 'Options:\n'
    printf '\t-h                  Print this Help\n'
    printf '\t-d                  Debug - print the command\n'
    printf '\t-i                  Case insensitive\n'
    printf '\t-v                  Exclude pattern\n'
    printf '\t-x                  Disable bat parsing\n'
}

function pawk() {
    [ $# -lt 2 ] && pawk_usage && return 1

    # Parse args
    while :; do
        if [[ $# -eq 0 ]]; then
            break
        elif [[ $1 =~ ^- ]]; then
            case $1 in
                -d)      local pawk_debug=1                           ;;
                -h)      pawk_usage && return 0                       ;;
                -i)      local pawk_case_insensitive=1                ;;
                -v)      local pawk_exclude=1                         ;;
                -x)      local skip_bat=1                             ;;
                *)       echo 'Error: Invalid option' && return 1     ;;
            esac
            shift
        else
            local pattern=$1
            local file=$2
            shift; shift
        fi
    done

    local section="'"
    if [[ -n $pawk_case_insensitive ]]; then
        pattern=$(echo ${pattern} | awk '{print tolower($0)}')
        section+='tolower($0)'
        if [[ -n $pawk_exclude ]]; then
            section+='!~'
        else
            section+='~'
        fi
    elif [[ -n $pawk_exclude ]]; then
        section+='!'
    fi
    section+="/$pattern/'"

    if type -P bat &>/dev/null; then
        if [[ -z $skip_bat ]]; then
            local bat_lang="$(IFS='.' read -a test <<< $(echo ${file} | awk -F/ '{print $NF}') && echo ${test[1]})"
            if [ ${#bat_lang} -gt 0 ]; then
                local bat_addon="| bat -l ${bat_lang}"
            else
                local bat_addon="| bat"
            fi
        fi
    fi
    local pawk_cmd="awk ${section} RS='\\n\\n' ORS='\\n\\n' ${file} ${bat_addon}"
    if [[ -n $pawk_debug ]]; then
        echo "Running: ${pawk_cmd}"
    fi
    eval ${pawk_cmd}
}
