# Forked from: joseph.tingiris@gmail.com
# 2023.02.07 - ducet8@outlook.com

function bash_logout() {
    bash_logout_message="$(date) logout ${USER}@${HOSTNAME}"

    if [[ "${BD_OS,,}" =~ 'alpine' ]]; then 
        export bash_pids=($(ps -ef | grep ${USER} | grep [b]ash | awk '{print $1}'))
    else
        # prep sshAgentInit to clean up when the last $USER is logging out
        export bash_pids=($(pgrep -u ${USER} bash)) # this creates a subshell, so 2=1?
    fi

    export bash_logins=${#bash_pids[@]}
    bash_logout_message+=" (bash_logins=${bash_logins})"

    if [ ${bash_logins} -lt 2 ]; then
        bash_logout_message+=' (last login)'
        bd_ansi_color="fg_yellow4"
    else
        bd_ansi_color="fg_yellow3"
    fi

    if [ ${#bash_logout} -eq 0 ]; then
        bd_ansi reset && bd_ansi ${bd_ansi_color}
        printf "${bash_logout_message}\n"
        bd_ansi reset
    fi

    if [ ${bash_logins} -lt 2 ] && [ "${USER}" == "${BD_USER}" ]; then
        # last login
        if [[ "${SSH_AGENT_PID}" =~ ^[0-9].+ ]]; then
            kill -9 "${SSH_AGENT_PID}" &> /dev/null
        fi

        # if [ "$(type -t sshAgentInit)" == 'function' ]; then
        #     sshAgentInit
        # fi

        unset -v SSH_AGENT_PID SSH_AUTH_SOCK
    fi

    export bash_logout=0

    if [ "$SHLVL" = 1 ]; then
        [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
    fi
}

# Trap EXIT; ensure bash_logout gets called, regardless

if  [ "$(type -t bash_logout)" == "function" ]; then
    if [ ${#TMUX_PANE} -eq 0 ]; then
        trap "bash_logout" EXIT
    else
        trap "bash_logout;tmux kill-pane -t ${TMUX_PANE}" EXIT
    fi
else
    if  [ "$(type -t bash_logout)" == "function" ]; then
        if [ ${#TMUX_PANE} -eq 0 ]; then
            trap "bash_logout" EXIT
        else
            trap "bash_logout;tmux kill-pane -t ${TMUX_PANE}" EXIT
        fi
    fi
fi
