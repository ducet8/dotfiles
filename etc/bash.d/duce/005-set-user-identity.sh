# Forked from: joseph.tingiris@gmail.com
# 2022.12.19 - ducet8@outlook.com

# set user identity variables

[ "$EUID" == "0" ] && USER="root"

# ${User_Name}
if [ -f ~/.User_Name ]; then
    User_Name="$(head -1 ~/.User_Name | tr -d '\n')"
else
    if (type -P logname &> /dev/null) && [[ "${BD_OS,,}" != "darwin" ]]; then
        User_Name=$(logname 2> /dev/null)
    else
        if type -P who &> /dev/null; then
            User_Name=$(who -m | awk '{print $1}' 2> /dev/null)
        fi
    fi
fi
[ ${#User_Name} -eq 0 ] && [ ${#SUDO_USER} -ne 0 ] && User_Name=${SUDO_USER}
[ ${#User_Name} -eq 0 ] && User_Name=${USER}
export User_Name

# ${Who}
[ ${#User_Name} -gt 0 ] && Who="${User_Name%% *}"
[ ${#Who} -eq 0 ] && [ ${#USER} -eq 0 ] && Who=${USER}
[ ${#Who} -eq 0 ] && [ ${#LOGNAME} -gt 0 ] && Who=${LOGNAME}
[ ${#Who} -eq 0 ] && Who="UNKNOWN"
export Who

# ${User_Dir}
if [ ${#Who} -eq 0 ] || [ ${Who} == "UNKNOWN" ]; then
    User_Dir="/tmp"
else
    unset User_Dir
    if type -P getent &> /dev/null; then
        User_Dir=$(getent passwd ${Who} 2> /dev/null | awk -F: '{print $6}' | tr -d '\n')
    fi
fi

if [ ${#User_Dir} -eq 0 ]; then
    if [ ${#HOME} -gt 0 ]; then
        User_Dir="${HOME}"
    else
        User_Dir="~"
    fi
fi
export User_Dir

# correct bash_profile ownership
if [ ${#User_Name} -gt 0 ] && [ "${USER}" != "root" ]; then
    for profile in "${User_Dir}/.bash_profile"*; do
        chown ${User_Name} "${profile}" &> /dev/null
    done
    unset profile
fi

# (reusable) apex & base user variables
export Apex_User=${Who}@${HOSTNAME}
export Base_User=${Apex_User}
