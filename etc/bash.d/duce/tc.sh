# vim: ft=sh
# 2023.08.10 - ducet8@outlook.com

tc() {
    local usage="Usage: tc <option>\n\tOptions:\n\t\t-h|--help        Displays this help\n\t\t-c|--current     Displays the current week's .timecard details\n\t\t-p|--previous    Displays the previous week's .timecard details\n\t\t-e|--edit        Opens a vi session for .timecard\n\n"
    if [ $# -ne 1 ]; then
        printf "${usage}"
        return 1
    fi
    
    local filename="${HOME}/.timecard"
    if [ ! -f "${filename}" ]; then
        echo "Error: File '${filename}' not found."
        return 1
    fi
    
    case ${1} in
	-h|--help)
	    printf "${usage}"
	    return 0
	    ;;
        -c|--current)
            local last_delimiter_line=$(grep -n "####" "${filename}" | tail -n 1 | cut -d ":" -f 1)
    
            if [ -z "${last_delimiter_line}" ]; then
                echo "Error: Could not find delimiter '####' in the file."
                return 1
            fi
    
            sed -n "$((last_delimiter_line + 1)),$ p" "${filename}"
	    ;;
        -e|--edit)
	    vi "${filename}"
	    ;;
	-p|--previous)
            local start_line=$(grep -n "####" "${filename}" | tail -n 2 | head -n 1 | cut -d ":" -f 1)
            local end_line=$(grep -n "####" "${filename}" | tail -n 1 | cut -d ":" -f 1)
    
            if [ -z "${start_line}" ] || [ -z "${end_line}" ]; then
                echo "Error: Could not find delimiter '####' in the file."
                return 1
            fi
    
            sed -n "$((start_line + 1)),$((end_line - 1))p" "${filename}"
            ;;
	*)
	    printf "INVALID OPTION: '${{1}'\n\n"
	    printf "${usage}"
	    return 1
	    ;;
    esac
}
