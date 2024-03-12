# vim: ft=sh
# 2024.03.12 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P az &>/dev/null; then
    return 1
fi

if ! type -P harlequin &>/dev/null; then
    return 1
fi

hq() {
    local hq_version="1.0.0-a"

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "hq"
            bd_ansi reset
            printf "\t${hq_version}\n"
            printf "Connects to a postgres database using harlequin\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\thq [OPTIONS]\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-d|--database"
            bd_ansi reset
            printf "   Specify the database to connect to (REQUIRED)\n"
            bd_ansi fg_blue1
            printf "\t-e|--env"
            bd_ansi reset
            printf "        Specify the environment (Default: dev)\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "       Show this help message and exit\n"
            bd_ansi reset
        else
            printf "hq\t${hq_version}\n"
            printf "Connects to a postgres database using harlequin\n\n"
            printf "USAGE:\n"
            printf "\thq [OPTIONS]\n"
            printf "OPTIONS:\n"
            printf "\t-d|--database   Specify the database to connect to (REQUIRED)\n"
            printf "\t-e|--env        Specify the environment (Default: dev)\n"
            printf "\t-h|--help       Show this help message and exit\n"
        fi
    }

    if [ $# -lt 2 ]; then
        print_help
        return 1
    fi
    
    while [ $# -gt 0 ]; do
        case ${1} in
            -h|--help)
                print_help
                return 0
                ;;
            -d|--database)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    local database="${1%/}"
                    shift
                else
                    echo 'Error: -d flag requires a database argument.'
                    return 1
                fi
                ;;
            -e|--env)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    local environment="${1%/}"
                    shift
                else
                    echo 'Error: -e flag requires a environment argument.'
                    return 1
                fi
                ;;
            *)
                printf "INVALID OPTION: '${{1}'\n\n"
                print_help
                return 1
                ;;
        esac
    done

    if [ -z ${environment} ]; then
        local environment="dev"
    fi

    local pguser="${USER}_cspire.com#EXT#@launchdeckcspire.onmicrosoft.com"

    export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query "[accessToken]" -o tsv) 
    harlequin -a postgres -h launchdeck-${environment}-core.postgres.database.azure.com -u ${pguser} --password $PGPASSWORD -d ${database}
}
