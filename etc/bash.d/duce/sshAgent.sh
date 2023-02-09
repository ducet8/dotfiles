# Forked from: joseph.tingiris@gmail.com
# 2023.02.08 - ducet8@outlook.com

# bd_ansi mapping
# EMER - fg_red1
# ALERT - fg_red2
# ERROR - fg_red4
# WARN - fg_yellow2
# NOTICE - fg_magenta2
# DEBUG - fg_blue2 

function ssh_agent_msg () {
    # usage: ssh_agent_msg <color> <msg> [debug_level]
    if [ $# -lt 2 ]; then
        bd_ansi reset; bd_ansi fg_red1
        printf 'ERROR: bad ssh_agent_msg() call - not enough args\n'
        bd_ansi reset
        return 1
    fi

    if [ $# -eq 3 ]; then  # Debug level passed
        if [ ${3} -ge ${BD_DEBUG:-0} ]; then
            return 0
        fi
    fi

    bd_ansi reset; bd_ansi ${1}
    printf "${2}"
    bd_ansi reset
}

function ssh_agent_add_identities() {
    for key in $(ls ${BD_HOME}/.ssh/id* | grep -v .pub); do
        ssh_agent_msg fg_blue2 "Adding ${key} to the ssh-agent...\n\t"
        ssh-add ${key}
    done
}

function ssh_agent() {
    local num_of_agents=$(ps aux | grep ${USER} | grep [s]sh-agent | wc -l)

    # 1 running agent with no connection to an agent
    if [ ${num_of_agents} -eq 1 ] && [ $(ssh-add -l &> /dev/null; echo $?) -eq 2 ]; then
        ssh_agent_msg fg_blue2 'An ssh-agent is already running\n' 2

        # Valid .ssh_agent file found
        if [ -r ${BD_HOME}/.ssh/.ssh_agent ]; then
            ssh_agent_msg fg_blue2 "\tAttaching to existing ssh-agent using ${BD_HOME}/.ssh/ssh-agent\n" 2
            eval $(<${BD_HOME}/.ssh/.ssh_agent) > /dev/null
        else
            ssh_agent_msg fg_blue2 '\tNo .ssh_agent file found. Killing existing agent...\n' 2
            kill -9 $(ps aux | grep ${USER} | grep [s]sh-agent | awk '{print $2}')
            unset SSH_AGENT_PID SSH_AUTH_SOCK
        fi

        num_of_agents=$(ps aux | grep ${USER} | grep [s]sh-agent | wc -l)
    fi

    # More than 1 running agents
    if [ ${num_of_agents} -gt 1 ]; then
        ssh_agent_msg fg_yellow2 "Multiple ssh-agents running\n" 2

        # Valid .ssh_agent file found
        if [ -r ${BD_HOME}/.ssh/.ssh_agent ]; then
            local agent_pid=$(grep SSH_AGENT_PID ${BD_HOME}/.ssh/.ssh_agent | cut -d ';' -f1 | awk -F= '{print $2}')
            if [[ ${agent_pid} =~ ^[0-9]+$ ]]; then
                ps -ef | grep ${agent_pid} | grep [s]sh-agent &> /dev/null
                # ssh-agent used in .ssh_agent is still running
                if [ $? == 0 ]; then
                    ssh_agent_msg fg_yellow2 "\tKilling ssh-agents not associated with ${BD_HOME}/.ssh/.ssh_agent [${agent_pid}]\n" 2
                    kill -9 $(ps aux | grep ${USER} | grep [s]sh-agent | grep -v ${agent_pid} | awk '{print $2}') &> /dev/null
                    unset SSH_AGENT_PID SSH_AUTH_SOCK
                    eval $(<{BD_HOME}/.ssh/.ssh_agent)
                else  # Not still running
                    ssh_agent_msg fg_yellow2 "\tKilling all running ssh-agents...\n" 2
                    kill -9 $(ps aux | grep ${USER} | grep [s]sh-agent | awk '{print $2}') &> /dev/null
                    ssh_agent_msg fg_yellow2 "\tRemoving stale ${BD_HOME}/.ssh/.ssh_agent\n" 2
                    rm -f ${BD_HOME}/.ssh/.ssh_agent &> /dev/null
                    unset SSH_AGENT_PID SSH_AUTH_SOCK
                fi
            else  # Invalid ssh-agent PID
                ssh_agent_msg fg_yellow2 "\tInvalid ssh-agent PID in ${BD_HOME}/.ssh/.ssh_agent [${agent_pid}]\n" 2
                ssh_agent_msg fg_yellow2 "\tKilling all running ssh-agents...\n" 2
                kill -9 $(ps aux | grep ${USER} | grep [s]sh-agent | awk '{print $2}') &> /dev/null
                ssh_agent_msg fg_yellow2 "\tRemoving stale ${BD_HOME}/.ssh/.ssh_agent\n" 2
                rm -f ${BD_HOME}/.ssh/.ssh_agent &> /dev/null
                unset SSH_AGENT_PID SSH_AUTH_SOCK
            fi
        else 
            ssh_agent_msg fg_yellow2 "\tFile not found: ${BD_HOME}/.ssh/.ssh_agent\n" 2
            ssh_agent_msg fg_yellow2 "\tKilling all running ssh-agents...\n" 2
            kill -9 $(ps aux | grep ${USER} | grep [s]sh-agent | awk '{print $2}')
            unset SSH_AGENT_PID SSH_AUTH_SOCK
        fi
        
        num_of_agents=$(ps aux | grep ${USER} | grep [s]sh-agent | wc -l)
    fi

    # No running agents and no keys connection to an agent
    if [ ${num_of_agents} -eq 0 ] && [ $(ssh-add -l &>/dev/null; echo $?) -eq 2 ]; then
        # Stale .ssh-agent file left behind
        if [ -r ${BD_HOME}/.ssh/.ssh_agent ]; then
            ssh_agent_msg fg_yellow2 "Removing stale ${BD_HOME}/.ssh/.ssh_agent\n"
            rm -f ${BD_HOME}/.ssh/.ssh_agent &> /dev/null
        fi
        
        ssh_agent_msg fg_blue2 'Starting ssh-agent\n' 2
        
        ssh-agent -t 24h > ${BD_HOME}/.ssh/.ssh_agent && chmod 600 ${BD_HOME}/.ssh/.ssh_agent
        eval $(<{BD_HOME}/.ssh/.ssh_agent)
    fi

    # Finally, verify identities are loaded
    if [ $(ssh-add -l &>/dev/null; echo $?) -eq 1 ]; then
        ssh_agent_add_identities
    fi
}

ssh_agent
