# vim: ft=sh
# 2026.02.24 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P az &>/dev/null; then
    return 0
fi

az-get-app-reg-clientid() {
    local version='1.0.0'

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf 'az-get-app-reg-clientid'
            bd_ansi reset
            printf "\t${version}\n"
            printf 'Gets the client ID (appId) for an Azure AD app registration by display name\n\n'
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\taz-get-app-reg-clientid <display-name>\n'
            bd_ansi fg_yellow3
            printf 'OPTIONS:\n'
            bd_ansi fg_blue1
            printf '\t-h|--help'
            bd_ansi reset
            printf '     Displays this help message\n'
            bd_ansi fg_yellow3
            printf 'EXAMPLES:\n'
            bd_ansi reset
            printf '\taz-get-app-reg-clientid github-scamp-api\n'
        else
            printf "az-get-app-reg-clientid\t${version}\n"
            printf 'Gets the client ID (appId) for an Azure AD app registration by display name\n\n'
            printf 'USAGE:\n'
            printf '\taz-get-app-reg-clientid <display-name>\n'
            printf 'OPTIONS:\n'
            printf '\t-h|--help     Displays this help message\n'
            printf 'EXAMPLES:\n'
            printf '\taz-get-app-reg-clientid github-scamp-api\n'
        fi
    }

    abort_with_message() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_red1
            printf "\n✗ %s\n\n" "$*"
            bd_ansi reset
        else
            printf "\n✗ %s\n\n" "$*"
        fi
        return 1
    }

    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
    esac

    if [ -z "${1}" ]; then
        abort_with_message "A display name is required"
        print_help
        return 1
    fi

    local display_name="${1}"

    az ad app list --display-name "${display_name}" --query "[0].appId" -o tsv
}
