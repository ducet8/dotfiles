# bd-os.sh: set additional variables that identify the operating system details

# Copyright (C) 2018-2023 Joseph Tingiris <joseph.tingiris@gmail.com>
# https://github.com/bash-d/bd/blob/main/LICENSE.md

#
# metadata
#

# bash.d: exports BD_OS_ID BD_OS_MACHINE BD_OS_NAME BD_OS_PATH BD_OS_PLATFORM_ID BD_OS_PRETTY_NAME BD_OS_VARIANT BD_OS_VARIANT_ID BD_OS_VERSION BD_OS_VERSION_ID BD_OS_VERSION_MAJOR

#
# init
#

# prevent non-sourced execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (instead, 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

# BD_OS is set in bd.sh; if it's not set then return
[ ${#BD_OS} -eq 0 ] && return

#
# main
#

BD_OS_ID=""
unset -v BD_OS_MACHINE BD_OS_NAME BD_OS_PATH BD_OS_PLATFORM_ID BD_OS_PRETTY_NAME BD_OS_VARIANT BD_OS_VARIANT_ID BD_OS_VERSION BD_OS_VERSION_ID BD_OS_VERSION_MAJOR

if [ "${BD_OS}" == 'darwin' ]; then
    BD_OS_ID="${BD_OS}"
    if [ -x /usr/bin/sw_vers ]; then
        BD_OS_NAME=$(/usr/bin/sw_vers -productName 2> /dev/null)
        BD_OS_VERSION=$(/usr/bin/sw_vers -buildVersion 2> /dev/null)
        BD_OS_VERSION_ID=$(/usr/bin/sw_vers -productVersion 2> /dev/null)
    fi
    [ ${#BD_OS_NAME} -gt 0 ] && [ ${#BD_OS_VERSION_ID} -gt 0 ] && BD_OS_PRETTY_NAME="${BD_OS_NAME} ${BD_OS_VERSION_ID}"
fi

if [ "${BD_OS}" == 'linux' ]; then
    if [ ${#BD_OS_ID} -eq 0 ] && [ -r /etc/os-release ]; then
        OIFS="${IFS}"
        while IFS='=' read -r BD_OS_RELEASE_KEY BD_OS_RELEASE_VALUE; do 
            BD_OS_RELEASE_VALUE=${BD_OS_RELEASE_VALUE//\"}
            if [ "${BD_OS_RELEASE_KEY}" == 'ID' ]; then 
                BD_OS_ID="${BD_OS_RELEASE_VALUE}"
            fi 

            if [ "${BD_OS_RELEASE_KEY}" == 'NAME' ]; then 
                BD_OS_NAME="${BD_OS_RELEASE_VALUE}"
            fi 

            if [ "${BD_OS_RELEASE_KEY}" == 'PLATFORM_ID' ]; then 
                BD_OS_PLATFORM_ID="${BD_OS_RELEASE_VALUE}"
            fi 

            if [ "${BD_OS_RELEASE_KEY}" == 'PRETTY_NAME' ]; then 
                BD_OS_PRETTY_NAME="${BD_OS_RELEASE_VALUE}"
            fi 

            if [ "${BD_OS_RELEASE_KEY}" == 'VARIANT' ]; then 
                BD_OS_VARIANT="${BD_OS_RELEASE_VALUE}"
            fi 

            if [ "${BD_OS_RELEASE_KEY}" == 'VARIANT_ID' ]; then 
                BD_OS_VARIANT_ID="${BD_OS_RELEASE_VALUE}"
            fi 

            if [ "${BD_OS_RELEASE_KEY}" == 'VERSION' ]; then 
                BD_OS_VERSION="${BD_OS_RELEASE_VALUE}"
            fi 

            if [ "${BD_OS_RELEASE_KEY}" == 'VERSION_ID' ]; then 
                BD_OS_VERSION_ID="${BD_OS_RELEASE_VALUE}"
            fi 
        done < /etc/os-release
        unset -v BD_OS_RELEASE_KEY BD_OS_RELEASE_VALUE
        IFS="${OIFS}" && unset OIFS
    fi

    [ ${#BD_OS_ID} -eq 0 ] && [ -r /etc/redhat-release ] && BD_OS_ID='rhel'
fi

if [ "${BD_OS}" == 'windows' ]; then
    [ -f /usr/bin/cygwin*.dll ] && BD_OS_ID="cygwin"
fi

if [ ${#BD_OS_ID} -gt 0 ]; then
    [ ${#BD_OS_PRETTY_NAME} -gt 0 ] && [ "${BD_OS}" == "wsl" ] && BD_OS_PRETTY_NAME+=" {WSL}"
    [ ${#BD_OS_VERSION_ID} -gt 0 ] && BD_OS_VERSION_MAJOR=${BD_OS_VERSION_ID%%.*}

    if type -P uname &> /dev/null; then
        BD_OS_MACHINE=$(uname -m 2> /dev/null)
        [ ${#BD_OS_VERSION_MAJOR} -gt 0 ] && BD_OS_PATH="${BD_OS_ID}/${BD_OS_VERSION_MAJOR}/${BD_OS_MACHINE}"
    fi
else
    BD_OS_ID="unknown"
fi

export BD_OS_ID BD_OS_MACHINE BD_OS_NAME BD_OS_PATH BD_OS_PLATFORM_ID BD_OS_PRETTY_NAME BD_OS_VARIANT BD_OS_VARIANT_ID BD_OS_VERSION BD_OS_VERSION_ID BD_OS_VERSION_MAJOR

bd_debug "BD_OS_ID = ${BD_OS_ID}" 1
