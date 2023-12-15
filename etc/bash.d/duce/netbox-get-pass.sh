# vim: ft=sh
# 2023.12.01 - ducet8@outlook.com


if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

netbox-get-pass() {
    local netbox_get_pass_version="1.1.0"

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "netbox-get-pass"
            bd_ansi reset
            printf "\t${netbox_get_pass_version}\n"
            printf "Get the password to the specified netbox instance and put it on the clipboard.\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\tnetbox-get-pass [-h|--help] -e|--environment <environment_name> -o|--organization <organization_name>\n"
            bd_ansi fg_yellow3
            printf "ARGS:\n"
            bd_ansi fg_blue1
            printf "\t-e|--environment"
            bd_ansi reset
            printf "      Specify the environment - Requires an enviroment listed after\n"
            bd_ansi fg_blue1
            printf "\t-o|--organization"
            bd_ansi reset
            printf "     Specify the organization - Requires an organization listed after\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "             Displays this help\n"
            bd_ansi reset
        else
            printf "netbox-get-pass\t${netbox_get_pass_version}\n"
            printf "Get the password to the specified netbox instance and put it on the clipboard.\n\n"
            printf "USAGE:\n"
            printf "\tnetbox-get-pass [-h|--help] -e|--environment <environment_name> -o|--organization <organization_name>\n"
            printf "ARGS:\n"
            printf "\t-e|--environment      Show this help message and exit\n"
            printf "\t-o|--organization     Show this help message and exit\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help             Show this help message and exit\n"
        fi
    }

    while [ $# -gt 0 ]; do
        case "${1}" in
            -e|--environment)
                shift
                if [ $# -gt 0 ]; then
                    local environment="${1}"
                else
                    if type bd_ansi &>/dev/null; then
                        bd_ansi fg_red1
                        printf "Environment must be provided with the -e|--environment flag\n\n"
                        bd_ansi reset
                    else
                        printf "Environment must be provided with the -e|--environment flag\n\n"
                    fi
                    print_help
                    return 1
                fi
                shift
                ;;
            -o|--organization)
                shift
                if [ $# -gt 0 ]; then
                    local organization="${1}"
                else
                    if type bd_ansi &>/dev/null; then
                        bd_ansi fg_red1
                        printf "Organization must be provided with the -o|--organization flag\n\n"
                        bd_ansi reset
                    else
                        printf "Organization must be provided with the -o|--organization flag\n\n"
                    fi
                    print_help
                    return 1
                fi
                shift
                ;;
            -h|--help)
                print_help
                return 0
                ;;
            *)
                print_help
                return 1
                ;;
        esac
    done

    if [ -z "${environment}" ] || [ -z "${organization}" ]; then
        print_help
        return 1
    fi

    local nbp="$(kubectl describe release/core-${environment}-env-org-${organization}-netbox -A --context ${environment}-crossplane | grep Password | awk -F: '{print $2}' | xargs)"
    echo "${nbp}" | pbcopy

    if type bd_ansi &>/dev/null; then
        bd_ansi fg_cyan3
        printf "Password copied to the clipboard for environment: "
        bd_ansi fg_blue1
        printf "${environment}"
        bd_ansi fg_cyan3
        printf ", organization: "
        bd_ansi fg_blue1
        printf "${organization}\n\n"
        bd_ansi reset
    else
        echo "Password copied to the clipboard for environment: ${environment}, organization: ${organization}"
        echo
    fi
}
