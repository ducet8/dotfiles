# vim: ft=sh
# 2024.08.02 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P az &>/dev/null; then
    return 0
fi

az-vault-add-ip(){
    local az_vault_add_ip='1.0.0-a'

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf 'az-vault-add-ip'
            bd_ansi reset
            printf "\t${az_vault_add_ip}\n"
            printf "Adds external IP to Azure vaults' firewall\n\n"
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\taz-vault-add-ip [OPTIONS]\n'
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
            printf "az-vault-add-ip\t${az_vault_add_ip}\n"
            printf "Adds external IP to Azure vaults' firewall\n\n"
            printf 'USAGE:\n'
            printf '\taz-vault-add-ip [OPTIONS]\n'
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

    local external_ip="$(curl -s ipinfo.io | jq -r '.ip')"

    for sub in "${subs[@]}"; do
        for name in $(az keyvault list --subscription "${sub}" --query "[].name" --output tsv); do 
            az keyvault network-rule add --subscription "${sub}" --ip "${external_ip}" --name "${name}" | jq
        done
    done
}
