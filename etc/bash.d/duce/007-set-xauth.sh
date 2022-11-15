# Forked from: joseph.tingiris@gmail.com

# If possible, as other users, xauth add ${User_Dir}/.Xauthority

if [ "${USER}" == "${Who}" ]; then
    if [ ${#DISPLAY} -eq 0 ] && [ ${#SSH_CONNECTION} -eq 0 ]; then
        export DISPLAY=:0
    fi
else
    bd_ansi reset; bd_ansi dim; bd_ansi fg_red
    echo "DEBUG: USER '${USER}' is NOT equal to Who '${Who}'"
    if [ ${#DISPLAY} -gt 0 ]; then
        if type -P xauth &> /dev/null; then
            bd_ansi reset; bd_ansi dim; bd_ansi fg_gray
            echo "DEBUG: xauth DISPLAY = ${DISPLAY}"
            if [ -r "${User_Dir}/.Xauthority" ]; then
                echo "DEBUG: ${User_Dir}/.Xauthority file found readable"
                while read Xauth_Add; do
                    xauth -b add ${Xauth_Add} 2> /dev/null
                done <<< "$(xauth -b -f "${User_Dir}/.Xauthority" list)"
            else
                bd_ansi reset; bd_ansi dim; bd_ansi fg_red
                echo "ALERT: ${User_Dir}/.Xauthority file not found readable"
            fi
        fi
    else
        export DISPLAY=:0
    fi
fi
bd_ansi reset
