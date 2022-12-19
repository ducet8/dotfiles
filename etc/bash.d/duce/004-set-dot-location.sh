# 2022.12.19- ducet8@outlook.com

# Set the DOT_LOCATION environment variable

if [[ -z "${SUDO_USER}" ]]; then
    export DOT_LOCATION="${HOME}"
else
    if [[ ${BD_OS,,} == "darwin" ]]; then
        export DOT_LOCATION="$(finger ${SUDO_USER} | awk '/^Directory/ {print $2}')"
    else
        cat /etc/passwd | grep duce &>/dev/null
        if [ $? -eq 0 ]; then
            export DOT_LOCATION="$(cat /etc/passwd | grep -i "${SUDO_USER}" | cut -d: -f6)"
        else
            # Trying to catch non passwd entries
            if [[ "${BD_OS,,}" == "darwin" ]]; then
                ls -l /Users/ | grep ${USER} &>/dev/null
                if [ $? -eq 0 ]; then
                    export DOT_LOCATION="/Users/${USER}"
                fi
            else
                ls -l /home/ | grep ${USER} &>/dev/null
                if [ $? -eq 0 ]; then
                    export DOT_LOCATION="/home/${USER}"
                fi
            fi
        fi
    fi
fi

if [[ -z "${DOT_LOCATION}" ]]; then
    bd_ansi fg_red
    echo "ALERT: DOT_LOCATION did not get set"
    bd_ansi reset
fi
