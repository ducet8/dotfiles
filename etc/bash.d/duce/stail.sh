# Forked from https://gist.github.com/Sidneys1/8973f8868300c8bac2e714de3d99ede4
# 2023.02.23 - ducet8@outlook.com
# vim: ft=sh

function stail() {
    local help opt out prefix lines out whitespace

    help="Usage: $0 [-n LINES] [-p PREFIX] [-w] [-h]
    Continuously displays the last '-n' lines of 'stdin'.
    Parameters:
      -n         Number of lines to display (default: 5).
      -p PREFIX  Prefix lines with 'PREFIX'.
      -w         Preserve blank lines (default: false).
      -h         Display this help
    ";

    # Process options
    while getopts 'hn:p:o:w' opt; do
        case "${opt}" in
            o)
                out="${OPTARG}";
                if ! touch "${out}"; then
                    bd_ansi reset && bd_ansi fg_red1
                    echo "Failed to create output file."
                    bd_ansi reset
                    exit 2;
                fi;;
            p) 
                # prefix="$(tput sgr0)${OPTARG}";;
                prefix="${OPTARG}";;
            n) 
                lines="${OPTARG}"
                [ -n "${lines}" ] && [ "${lines}" -eq "${lines}" ] 2>/dev/null
                if [ $? -ne 0 ] || [ "${lines}" -lt 1 ]; then
                    bd_ansi reset && bd_ansi fg_red1
                    echo "-n LINES must be a number greater than 0"
                    bd_ansi reset
                    exit 2;
                fi;;
            w) 
                whitespace=false;;
            h|*) 
                bd_ansi reset && bd_ansi fg_yellow4
                echo "${help}"
                bd_ansi reset
                exit 2;;
        esac
    done

    # Check for unexpected options
    shift "$((OPTIND - 1))"
    if [ -n "$*" ]; then
        bd_ansi reset && bd_ansi fg_red1
        echo "Unexpected options: $*"
        bd_ansi reset && bd_ansi fg_yellow4
        echo "${help}"
        bd_ansi reset
        exit 2
    fi

    lines="${lines:-5}"
    out="${out:-/dev/null}"
    whitespace="${whitespace:-true}"

    width="$(stty size </dev/tty | cut -d' ' -f2)"
    local trimmed=$(echo "${prefix}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    (( width-=${#trimmed} ))

    i=0
    while IFS= read -r line; do
        if ${whitespace}; then
            case "${line}" in
                (*[![:blank:]]*);;
                (*) continue;;
            esac
        fi
        if [[ $((++i)) -gt "${lines}" ]]; then
            tput cuu "${lines}"; tput dl1
            if [[ "${lines}" -gt 1 ]]; then
                tput cud "$(( lines - 1 ))"
            fi
        fi
        bd_ansi reset && bd_ansi fg_magenta2
        echo -n "${prefix}"
        bd_ansi reset
        echo "${line}" | cut -c1-${width}
    done < <(tee "${out}" </dev/stdin)
}
