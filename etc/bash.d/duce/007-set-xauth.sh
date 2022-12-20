# Forked from: joseph.tingiris@gmail.com
# 2022.12.20 - ducet8@outlook.com

# If possible, as other users, xauth add ${BD_HOME}/.Xauthority

if [ "${USER}" == "${BD_USER}" ]; then
    if [ ${#DISPLAY} -eq 0 ] && [ ${#SSH_CONNECTION} -eq 0 ]; then
        export DISPLAY=:0
    fi
else
    bd_ansi reset; bd_ansi dim; bd_ansi fg_red
    echo "DEBUG: USER '${USER}' is NOT equal to BD_USER '${BD_USER}'"
    if [ ${#DISPLAY} -gt 0 ]; then
        if type -P xauth &> /dev/null; then
            bd_ansi reset; bd_ansi dim; bd_ansi fg_gray
            echo "DEBUG: xauth DISPLAY = ${DISPLAY}"
            if [ -r "${BD_HOME}/.Xauthority" ]; then
                echo "DEBUG: ${BD_HOME}/.Xauthority file found readable"
                while read Xauth_Add; do
                    xauth -b add ${Xauth_Add} 2> /dev/null
                done <<< "$(xauth -b -f "${BD_HOME}/.Xauthority" list)"
            else
                bd_ansi reset; bd_ansi dim; bd_ansi fg_red
                echo "ALERT: ${BD_HOME}/.Xauthority file not found readable"
            fi
        fi
    else
        export DISPLAY=:0
    fi
fi
bd_ansi reset
