# 2022.11.07 - ducet8@outlook.com

# Paragraph grep

function pawk_usage() {
    printf "usage: $0 [-hvi] [pattern] [file]\n\n"
    
    printf "Options:\n"
    printf "\th                  Print this Help\n"
    printf "\td                  Debug - print the command\n"
    printf "\tv                  Exclude pattern\n"
    printf "\ti                  Case insensitive\n"

    exit 1
}

function pawk() {
    if [ "$1" == "" ] || [ "$2" == "" ]; then
        pawk_usage
    fi

    while getopts ":hdvi" option; do
        case $option in
            h)
            pawk_usage;;
            d)
            debug=1;;
            v)
            exclude=1;;
            i)
            case_insensitive=1;;
            \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
        esac
    done

    shift $((OPTIND-1))
    pattern=$1
    file=$2

    section="'"
    if [[ -n $case_insensitive ]]; then
        pattern=$(echo $pattern | awk '{print tolower($0)}')
        section+='tolower($0)'
        if [[ -n $exclude ]]; then
            section+='!~'
        else
            section+='~'
        fi
    elif [[ -n $exclude ]]; then
        section+='!'
    fi
    section+="/$pattern/'"

    cmd="awk ${section} RS='\\n\\n' ORS='\\n\\n' $file"
    if [[ -n $debug ]]; then
        echo "Running: $cmd"
    fi
    eval $cmd 
}
