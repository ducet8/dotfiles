# Forked from: joseph.tingiris@gmail.com
# 2022.11.09 - ducet8@outlook.com

function bash_logout() {
    Bash_Logout_Message="$(date) logout ${USER}@${HOSTNAME}"

    if [[ "${Os_Id,,}" =~ 'alpine' ]]; then 
        export Bash_Pids=($(ps -ef | grep ${USER} | grep [b]ash | awk '{print $1}'))
    else
        # prep sshAgentInit to clean up when the last $USER is logging out
        export Bash_Pids=($(pgrep -u ${USER} bash)) # this creates a subshell, so 2=1?
    fi

    export Bash_Logins=${#Bash_Pids[@]}
    Bash_Logout_Message+=" (Bash_Logins=${Bash_Logins})"

    if [ ${Bash_Logins} -lt 2 ]; then
        Bash_Logout_Message+=' (last login)'
        verbose_level=3
    else
        verbose_level=4
    fi

    if [ ${#Bash_Logout} -eq 0 ]; then
        if [ "$(type -t verbose)" == 'function' ]; then
            verbose "${Bash_Logout_Message}" $verbose_level
        else
            printf "${Bash_Logout_Message}\n"
        fi
    fi

    if [ ${Bash_Logins} -lt 2 ] && [ "${USER}" == "${Who}" ]; then
        # last login
        if [[ "${SSH_AGENT_PID}" =~ ^[0-9].+ ]]; then
            kill -9 "${SSH_AGENT_PID}" &> /dev/null
        fi

        if [ "$(type -t sshAgentInit)" == 'function' ]; then
            sshAgentInit
        fi

        unset -v SSH_AGENT_PID SSH_AUTH_SOCK
    fi

    export Bash_Logout=0

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