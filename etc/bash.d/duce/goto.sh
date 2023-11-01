# vim: ft=sh
# 2023.11.01 - ducet8@outlook.com

goto() {
    local version='2.0.0-a'

    print_help() {
        local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')
        local description="SSH and set the tabname (on MacOS) to the passed host"
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "${program}"
            bd_ansi reset
            printf "\t${version}\n"
            printf "${description}\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t${program} <host>\n"
            bd_ansi fg_yellow3
            printf "ARGUMENTS:\n"
            bd_ansi fg_blue1
            printf "\t<host>"
            bd_ansi reset
            printf "         The host to SSH to\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\tssh Options"
            bd_ansi reset
            printf "    Any ssh options will be passed through\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "      Display this help\n"
        else
            printf "${program}\t${version}\n"
            printf "${description}\n\n"
            printf "USAGE:\n"
            printf "\t${program} <host>\n"
            printf "ARGUMENTS:\n"
            printf "\t<host>         The host to SSH to\n"
            printf "OPTIONS:\n"
            printf "\tssh Options    Any ssh options will be passed through\n"
            printf "\t-h|--help      Display this help\n"
        fi
    }

    [ $# -lt 1 ] && print_help && return 1

    case "$1" in
        -h|--help)
            print_help
            return 0
            ;;
        *)
            local host="$(echo $@ | awk -F@ '{print $NF}' | awk '{print $NF}')"
            local ssh_user

            if [[ "$(echo $@ | awk '{print $NF}')" == *"@"* ]]; then
                ssh_user="$(echo $@ | awk '{print $NF}' | awk -F@ '{print $1}')"
            else
                ssh_user=${USER}
            fi

            [[ ${BD_OS,,} == "darwin" ]] && tabname "${ssh_user}@${host}"
            ssh ${@}
            ;;
    esac
}
