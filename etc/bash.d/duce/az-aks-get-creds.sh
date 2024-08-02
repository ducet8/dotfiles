# vim: ft=sh
# 2024.08.02 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P az &>/dev/null; then
    return 0
fi

az-aks-get-creds(){
    local az_aks_get_creds='1.0.0-a'

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf 'az-aks-get-creds'
            bd_ansi reset
            printf "\t${az_aks_get_creds}\n"
            printf 'Outputs the required commands to get the credentials for all AKS clusters\n\n'
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\taz-aks-get-creds [OPTIONS]\n'
            bd_ansi fg_yellow3
            printf 'OPTIONS:\n'
            bd_ansi fg_blue1
            printf '\t-e|--env'
            bd_ansi reset
            printf '      The Azure environment to search [all, dev, prod] (Default: all)\n'
            bd_ansi fg_blue1
            printf '\t-h|--help'
            bd_ansi reset
            printf '     Displays this help message\n'
            bd_ansi reset
        else
            printf "az-aks-get-creds\t${az_aks_get_creds}\n"
            printf 'Outputs the required commands to get the credentials for all AKS clusters\n\n'
            printf 'USAGE:\n'
            printf '\taz-aks-get-creds [OPTIONS]\n'
            printf 'OPTIONS:\n'
            printf '\t-e|--env      The Azure environment to search [all, dev, prod] (Default: all)\n'
            printf '\t-h|--help     Displays this help message\n'
        fi
    }

    # Process arguments
    while [ $# -gt 0 ]; do
        case "${1}" in
            -e|--env)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    local environment="${1%/}"
                    environment="${environment,,}"
                    shift
                else
                    echo 'Error: -e flag requires an environment argument.'
                    return 1
                fi
                ;;
            -h|--help)
                print_help
                return 0
                ;;
            *)
                echo 'Invalid option' && echo
                print_help
                return 1
                ;;
        esac
    done

    # Checks
    if [ -z ${environment} ]; then
        local environment="all"
    fi

    # Main
    if [[ "${environment}" == "all" ]]; then
        local subs=("${LD_AZURE_DEV_SUB_ID}" "${LD_AZURE_PROD_SUB_ID}")
    elif [[ "${environment}" == "dev" ]]; then
        local subs=("${LD_AZURE_DEV_SUB_ID}")
    elif [[ "${environment}" == "prod" ]]; then
        local subs=("${LD_AZURE_PROD_SUB_ID}")
    fi

    for sub in "${subs[@]}"; do
        az aks list --subscription "${sub}" --query "[].{name: name, resourceGroup: resourceGroup, id: id}" -o json | jq --arg subId "${sub}" -r '.[] | "az aks get-credentials --subscription \($subId) --resource-group \(.resourceGroup) --name \(.name)"'
    done
}
