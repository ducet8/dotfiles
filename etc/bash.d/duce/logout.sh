# Forked from: joseph.tingiris@gmail.com
# 2023.02.17 - ducet8@outlook.com

function bash_logout() {
    if [[ "${BD_OS_ID,,}" =~ 'alpine' ]] || [[ "${BD_OS,,}" == 'darwin' ]]; then 
        local bash_logins=($(ps aux | grep ${USER} | grep -c [b]ash))
    else
        local bash_logins=($(pgrep -u ${USER} -c bash))
    fi

    # Trap seems to create a subshell that shouldn't be counted
    if [ -n ${bash_logins} ]; then
        (( bash_logins-- ))
    fi

    bash_logout_message="$(date) logout ${USER}@${HOSTNAME} (bash_logins=${bash_logins})"
    bd_ansi reset
    if [ ${bash_logins} -lt 2 ]; then
        if [ ${#bash_logout} -eq 0 ]; then
            bd_ansi fg_yellow4 && printf "${bash_logout_message}"
            bd_ansi blink_fast && bd_ansi bold && printf ' (last login)\n' && bd_ansi reset_blink && bd_ansi reset_bold
            sleep_timer=1
        else
            sleep_timer=4
        fi
    else
        if [ ${#bash_logout} -eq 0 ]; then
            bd_ansi fg_yellow3 && printf "${bash_logout_message}\n"
            sleep_timer=1
        fi
    fi
    bd_ansi reset

    if [ ${bash_logins} -lt 2 ] && [ "${USER}" == "${BD_USER}" ]; then
        # Last login
        if [[ "${SSH_AGENT_PID}" =~ ^[0-9].+ ]]; then
            kill -9 "${SSH_AGENT_PID}" &> /dev/null
        fi

        unset -v SSH_AGENT_PID SSH_AUTH_SOCK
    fi

    local bash_logout=0

    # Sleep for future debugging when it is the last login
    if [ -n ${sleep_timer} ]; then
        sleep ${sleep_timer}
    fi

    if [ "$SHLVL" = 1 ]; then
        [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
    fi
}

# Trap EXIT
if  [ "$(type -t bash_logout)" == "function" ]; then
    if [ ${#TMUX_PANE} -eq 0 ]; then
        trap "bash_logout" EXIT
    else
        trap "bash_logout;tmux kill-pane -t ${TMUX_PANE}" EXIT
    fi
fi
