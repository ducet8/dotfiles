# vim: ft=sh
# .bash_profile
bash_profile_date="2025.06.10"
BASH_PROFILE_VERSION="${bash_profile_date}, ducet8@outlook.com"
unset bash_profile_date


##
# Debugging with file descriptors and time
##
# TODO: Add a safety to this
time_debug=1  # 0 is on/1 is off
if [[ ${time_debug} -eq 0 ]] && type -P /usr/local/bin/ts &>/dev/null; then
    # This line will give vim syntax error, but it works
    exec {FD}> >(/usr/local/bin/ts -i "%.s" >> /tmp/profile_debug)
    export BASH_XTRACEFD="$FD"
    set -x
fi


##
# Returns to Avoid Interactive Shell Enhancements
##
case $- in
    *i*)            ;;          # interactive shell (OK)
    *)      return  ;;          # non-interactive shell
esac

# Do not allow execution
[ "${BASH_SOURCE}" == "${0}" ] && exit

# No prompt
if [ ${#PS1} -le 0 ]; then return; fi

# SSH, No TTY,No TMUX
if [ ${#SSH_CONNECTION} -gt 0 ] && [ ${#SSH_TTY} -eq 0 ] && [ ${#TMUX} -eq 0 ]; then return; fi

# Source the system bashrc
if [ -f /etc/bashrc ]; then source /etc/bashrc; fi


##
# bash.d
##
#[ "${USER}" != 'root' ] && [ -r ~/etc/bash.d/00bd.sh ] && export BD_DEBUG=0 && source ~/etc/bash.d/00bd.sh ${@}
#[ "${USER}" == 'root' ] && [ -r ${BD_HOME}/etc/bash.d/00bd.sh ] && export BD_DEBUG=0 && source ${BD_HOME}/etc/bash.d/00bd.sh ${@}
if [ -z ${BD_HOME} ] || [ "${USER}" != 'root' ]; then
    [ -r ~/.bd/bd.sh ] && export BD_DEBUG=0 && export BD_ANSI_EXPORT=1 && source ~/.bd/bd.sh ${@}
else
    [ -r ${BD_HOME}/.bd/bd.sh ] && export BD_DEBUG=0 && export BD_ANSI_EXPORT=1 && source ${BD_HOME}/.bd/bd.sh ${@}
    # If user isn't BD_USER, go home
    if [ "${BD_HOME}" != "${HOME}" ]; then
        cd ${HOME}
    fi
fi
