# vim: ft=sh
# 2023.07.28 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

function monitor() {
    # TODO: Allow custom message 
    # TODO: Handle multiple word commands without quotes
    # TODO: Handle commands like sleep that take an integer
    
    local help msg program
    
    local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')

    help="Usage: ${program} [-h] \"command to run\"
    Runs a command with an audible annoucement when it is complete.
    Parameters:
      -h         Display this help
    ";

    msg="hey I'm done"

    if [ -z ${1} ]; then
        echo "${help}"
        echo 'ERROR: <monitor> is missing arguments' >&2
        return 1
    fi

    if [ "${1}" == '-h' ]; then
        echo "${help}"
        return 0
    fi

    ${*}; say "${msg}"
}

