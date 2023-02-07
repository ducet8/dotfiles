 # 2023.01.25 - ducet8@outlook.com

Sudo="$(type -P sudo 2> /dev/null)"
[ ! -x ${Sudo} ] && unset Sudo

if [ ${#Sudo} -gt 0 ]; then
    alias root="${Sudo} --preserve-env=SSH_AUTH_SOCK,BD_HOME,BD_USER -u root ${SHELL} --init-file ${BD_HOME}/.bash_profile"
    alias suroot="${Sudo} --preserve-env=SSH_AUTH_SOCK,BD_HOME,BD_USER -u root -"
else
    alias root="su - root -c '${SHELL} --init-file ${BD_HOME}/.bash_profile'"
    alias suroot='su -'
fi

# function 
