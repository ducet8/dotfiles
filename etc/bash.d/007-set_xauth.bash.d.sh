#!/usr/bin/env bash
# If possible, as other users, xauth add ${User_Dir}/.Xauthority

if [ "${USER}" == "${Who}" ]; then
    # elog -q debug "USER '${USER}' is equal to Who '${Who}'"
    if [ ${#DISPLAY} -eq 0 ] && [ ${#SSH_CONNECTION} -eq 0 ]; then
        export DISPLAY=:0
    fi
else
    elog -q debug "USER '${USER}' is NOT equal to Who '${Who}'"
    if [ ${#DISPLAY} -gt 0 ]; then
        if type -P xauth &> /dev/null; then
            elog -q debug "xauth DISPLAY=${DISPLAY}"
            if [ -r "${User_Dir}/.Xauthority" ]; then
                elog -q debug "${User_Dir}/.Xauthority file found readable"
                while read Xauth_Add; do
                    xauth -b add ${Xauth_Add} 2> /dev/null
                done <<< "$(xauth -b -f "${User_Dir}/.Xauthority" list)"
            else
                elog -q alert "${User_Dir}/.Xauthority file not found readable"
            fi
        fi
    else
        export DISPLAY=:0
    fi
fi

