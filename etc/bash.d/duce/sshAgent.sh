# Forked from: joseph.tingiris@gmail.com
# 2022.12.19 - ducet8@outlook.com

# if necessary, start ssh-agent
function sshAgent() {
    if ! sshAgentInit; then
        verbose 'ERROR: sshAgentInit failed'
        return 1
    fi

    verbose "DEBUG: Ssh_Agent_Home=${Ssh_Agent_Home}" 18
    verbose "DEBUG: Ssh_Agent_State=${Ssh_Agent_State}" 18

    if [ ${#Ssh_Agent_Home} -gt 0 ]; then
        if [ ! -r "${Ssh_Agent_Home}" ]; then
            if [ -d "${HOME}/.ssh" ]; then
                # remind me; these keys probably shouldn't be here
                for Ssh_Key in "${HOME}/.ssh/id"*; do
                    if [ -r "${Ssh_Key}" ]; then
                        verbose "WARNING: no ${Ssh_Agent_Home}; found ssh key file on ${HOSTNAME} '${Ssh_Key}'"
                    fi
                done
                unset -v Ssh_Key
            fi
        fi

        if [ ${#SSH_AUTH_SOCK} -eq 0 ]; then
            if [ ! -r "${Ssh_Agent_Home}" ]; then
                # there's no .ssh-agent file and ssh agent forwarding is off
                verbose "NOTICE: no ${Ssh_Agent_Home}; ssh agent forwarding is off"
                return 0
            fi
        fi
    fi

    export Ssh_Agent="$(type -P ssh-agent)"
    if [ ${#Ssh_Agent} -eq 0 ] || [ ! -x ${Ssh_Agent} ]; then
        verbose 'ERROR: ssh-agent not usable'
        return 1
    fi

    export Ssh_Keygen="$(type -P ssh-keygen)"
    if [ ${#Ssh_Keygen} -eq 0 ] || [ ! -x ${Ssh_Keygen} ]; then
        verbose 'ERROR: ssh-keygen not usable'
        return 1
    fi

    # if needed then generate an ssh key
    if [ ! -d "${HOME}/.ssh" ]; then
        ${Ssh_Keygen} -t ecdsa -b 521
    fi

    if [ "${BD_OS}" != 'Darwin' ]; then
        # (re)start ssh-agent if necessary
        if [ ${#SSH_AGENT_PID} -eq 0 ] && [ ${#SSH_AUTH_SOCK} -eq 0 ]; then
            if [ ${#Ssh_Agent_Home} -gt 0 ] && [ -r "${Ssh_Agent_Home}" ]; then
                (umask 066; ${Ssh_Agent} -t ${Ssh_Agent_Timeout} 1> ${Ssh_Agent_State})
                eval "$(<${Ssh_Agent_State})" &> /dev/null
            fi
        fi
    fi

    # ensure ssh-add works or output an error message & return
    Ssh_Add_Out=$(${Ssh_Add} -l 2>&1)
    Ssh_Add_Rc=$?
    if [ ${Ssh_Add_Rc} -eq 0 ]; then
        if [ "${BD_OS}" != 'Darwin' ]; then
            if [ ${#SSH_AGENT_PID} -eq 0 ] && [ ${#SSH_AUTH_SOCK} -gt 0 ]; then
                # ssh-add works; ssh agent forwarding is on .. start another/local agent anyway?
                local ssh_agent_home_message="SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
                if [ ${#Ssh_Agent_Home} -gt 0 ] && [ -r "${Ssh_Agent_Home}" ]; then
                    ssh_agent_home_message+="; ignoring ${Ssh_Agent_Home}"
                fi
                verbose "NOTICE: ${ssh_agent_home_message}" 3
            fi
        fi
    else
        # starting ssh-add failed (the first time)
        # rc=1 means 'failure', it's unspecified and may just be that it has no identities
        if [[ "${Ssh_Add_Out}" != *'agent has no identities'* ]]; then
            verbose "ERROR: '${Ssh_Add}' failed with SSH_AGENT_PID=${SSH_AGENT_PID}, SSH_AUTH_SOCK=${SSH_AUTH_SOCK}, output='${Ssh_Add_Out}', Ssh_Add_Rc=${Ssh_Add_Rc}"
            unset -v SSH_AGENT_PID
            unset -v SSH_AUTH_SOCK
        fi
    fi
    unset -v Ssh_Add_Out Ssh_Add_Rc

    # always enable agent forwarding?
    if [ "${#SSH_AUTH_SOCK}" -gt 0 ]; then
        alias ssh='ssh -A'
    fi

    Ssh_Key_Files=()

    Ssh_Dirs=()
    Ssh_Dirs+=(${User_Dir})

    if [ "${User_Dir}" != "${HOME}" ]; then
        Ssh_Dirs+=(${HOME})
    fi

    verbose "DEBUG: Ssh_Dirs=${Ssh_Dirs[@]}" 22

    for Ssh_Dir in ${Ssh_Dirs[@]}; do
        if [ -r "${Ssh_Dir}/.ssh" ] && [ -d "${Ssh_Dir}/.ssh" ]; then
            while read Ssh_Key_File; do
                Ssh_Key_Files+=(${Ssh_Key_File})
            done <<< "$(find "${Ssh_Dir}/.ssh/" -user ${User_Name} -name "*id_ecdsa" -o -name "*id_rsa" -o -name "*ecdsa_key" -o -name "*id_ed25519" 2> /dev/null)"
        fi
    done
    unset -v Ssh_Add_Rc Ssh_Dir


    Ssh_Configs=()
    for Ssh_Dir in ${Ssh_Dirs[@]}; do
        Ssh_Configs+=("${Ssh_Dir}/.ssh/config")
        Ssh_Configs+=("${Ssh_Dir}/.git/GIT_SSH.config")
        Ssh_Configs+=("${Ssh_Dir}/.subversion/SVN_SSH.config")
    done
    unset -v Ssh_Dir

    verbose "DEBUG: Ssh_Configs=${Ssh_Configs[@]}" 22

    for Ssh_Config in ${Ssh_Configs[@]}; do
        if [ -r "${Ssh_Config}" ]; then
            while read Ssh_Key_File; do
                Ssh_Key_Files+=(${Ssh_Key_File})
            done <<< "$(grep IdentityFile "${Ssh_Config}" 2> /dev/null | awk '{print $NF}' | grep -v ".pub$" | sort -u)"
            unset -v Ssh_Key_File
        fi
    done
    unset -v Ssh_Config Ssh_Configs

    # TODO: syntax, find a different way to do this ...
    eval Ssh_Key_Files=($(printf "%q\n" "${Ssh_Key_Files[@]}" | sort -u))

    verbose "DEBUG: Ssh_Key_Files=${Ssh_Key_Files[@]}" 22

    local ssh_key_file_counter=0
    for Ssh_Key_File in ${Ssh_Key_Files[@]}; do
        Ssh_Agent_Key=""
        Ssh_Key_Public=""
        Ssh_Key_Private=""

        if [ -r "${Ssh_Key_File}.pub" ]; then
            Ssh_Key_Public=$(awk '{print $2}' "${Ssh_Key_File}.pub" 2> /dev/null)
            if [ ${#Ssh_Key_Public} -eq 0 ]; then
                # couldn't determine public key
                continue
            fi

            Ssh_Agent_Key=$(${Ssh_Add} -L  2> /dev/null | grep "${Ssh_Key_Public}" 2> /dev/null)
            if [ "${Ssh_Agent_Key}" != "" ]; then
                # public key is already in the agent
                continue
            fi

            # ensure the agent supports this key type
            ${Ssh_Keygen} -l -f "${Ssh_Key_File}.pub" &> /dev/null
            Ssh_Keygen_Rc=$?
            if [ ${Ssh_Keygen_Rc} -ne 0 ]; then
                # unsupported key type
                verbose "WARNING: ${Ssh_Key_File}.pub is of an unsupported key type"
                continue
            fi
            unset -v Ssh_Keygen_Rc

        else
            # key file is not readable
            continue
        fi

        let ssh_key_file_counter=${ssh_key_file_counter}+1

        if [ -r "${Ssh_Key_File}" ]; then
            Ssh_Key_Private=$(${Ssh_Keygen} -l -f "${Ssh_Key_File}.pub" 2> /dev/null | awk '{print $2}')
            if  [ ${#Ssh_Key_Private} -gt 0 ]; then
                Ssh_Agent_Key=$(${Ssh_Add} -l 2> /dev/null | grep ${Ssh_Key_Private} 2> /dev/null)
                if [ "${Ssh_Agent_Key}" == "" ]; then

                    # add the key to the agent
                    ${Ssh_Add} ${Ssh_Key_File} &> /dev/null
                    Ssh_Add_Rc=$?
                    if [ ${Ssh_Add_Rc} -ne 0 ]; then
                        verbose "ERROR: '${Ssh_Add} ${Ssh_Key_File}' failed, Ssh_Add_Rc=${Ssh_Add_Rc}"
                    fi
                    unset -v Ssh_Add_Rc

                fi
                unset -v Ssh_Agent_Key
            fi
        fi
    done
    unset -v Ssh_Agent_Key Ssh_Key_File Ssh_Key_Private Ssh_Key_Public Ssh_Key_Files

    # hmm .. https://serverfault.com/questions/401737/choose-identity-from-ssh-agent-by-file-name
    # this will convert the stored ssh-keys to public files that can be used with IdentitiesOnly
    Md5sum="$(type -P md5sum)"
    if [ -x "${Md5sum}" ] && [ -w "${HOME}/.ssh" ] && [ "${USER}" != "root" ]; then
        Ssh_Identities_Dir="${HOME}/.ssh/md5sum"

        if [ ! -d "${Ssh_Identities_Dir}" ]; then
            mkdir -p "${Ssh_Identities_Dir}"
            Mkdir_Rc=$?
            if [ ${Mkdir_Rc} -ne 0 ]; then
                verbose "EMERGENCY: failed to 'mkdir -p ${Ssh_Identities_Dir}', Mkdir_Rc=${Mkdir_Rc}"
                return 1
            fi
            unset -v Mkdir_Rc
        fi

        chmod 0700 "${Ssh_Identities_Dir}" &> /dev/null
        Chmod_Rc=$?
        if [ ${Chmod_Rc} -ne 0 ]; then
            verbose "EMERGENCY: failed to 'chmod -700 ${Ssh_Identities_Dir}', Chmod_Rc=${Chmod_Rc}"
            return 1
        fi
        unset -v Chmod_Rc

        while read Ssh_Public_Key; do
            Ssh_Public_Key_Md5sum=$(printf "${Ssh_Public_Key}" | awk '{print $2}' | ${Md5sum} | awk '{print $1}')
            if [ "${Ssh_Public_Key_Md5sum}" != "" ]; then
                if [ -f "${Ssh_Identities_Dir}/${Ssh_Public_Key_Md5sum}.pub" ]; then
                    continue
                fi
                printf "${Ssh_Public_Key}" > "${Ssh_Identities_Dir}/${Ssh_Public_Key_Md5sum}.pub"
                chmod 0400 "${Ssh_Identities_Dir}/${Ssh_Public_Key_Md5sum}.pub" &> /dev/null
                Chmod_Rc=$?
                if [ ${Chmod_Rc} -ne 0 ]; then
                    verbose "EMERGENCY: failed to 'chmod 0400 ${Ssh_Identities_Dir}/${Ssh_Public_Key_Md5sum}.pub', Chmod_Rc=${Chmod_Rc}"
                    return 1
                fi
                unset -v Chmod_Rc
            fi
            unset -v Ssh_Public_Key_Md5sum
        done <<< "$(${Ssh_Add} -L 2> /dev/null)"
        unset -v Ssh_Public_Key
    fi

}

function sshAgentInit() {
    alias authsock=sshAgentInit

    if [[ ! ${Ssh_Agent_Clean_Counter} =~ ^[0-9]+$ ]]; then
        Ssh_Agent_Clean_Counter=0
    fi

    let Ssh_Agent_Clean_Counter=${Ssh_Agent_Clean_Counter}+1

    if [ ${Ssh_Agent_Clean_Counter} -gt 2 ]; then
        return 1 # prevent infinite, recursive loops
    fi

    export Ssh_Add="$(type -P ssh-add)"
    if [ ${#Ssh_Add} -eq 0 ] || [ ! -x ${Ssh_Add} ]; then
        pkill ssh-agent &> /dev/nulll
        verbose "EMERGENCY: ssh-add not usable"
        return 1
    fi

    export Ssh_Agent_Home="${User_Dir}/.ssh-agent"
    export Ssh_Agent_State="${Ssh_Agent_Home}.${Who}@${HOSTNAME}"
    export Ssh_Agent_Timeout=86400

    if [ ${#SSH_AUTH_SOCK} -eq 0 ]; then
        if [ -s "${Ssh_Agent_State}" ]; then
            # agent state file exists and it's not empty, try to use it
            eval "$(<${Ssh_Agent_State})" &> /dev/null
        fi
    fi

    local ssh_agent_socket_command

    if [ ${#SSH_AGENT_PID} -gt 0 ]; then
        ssh_agent_socket_command=$(ps -h -o comm -p ${SSH_AGENT_PID} 2> /dev/null)
        if [ ${#ssh_agent_socket_command} -gt 0 ] && [ "${ssh_agent_socket_command}" != "ssh-agent" ] && [ "${ssh_agent_socket_command}" != "sshd" ]; then
            verbose "ERROR: SSH_AGENT_PID=${SSH_AGENT_PID} process not valid; missing or defunct\n"
            kill -9 ${SSH_AGENT_PID} &> /dev/null
            unset -v SSH_AGENT_PID
        fi
    fi

    if [ ${#SSH_AUTH_SOCK} -gt 0 ]; then
        if [ -S "${SSH_AUTH_SOCK}" ]; then
            if [ ! -w "${SSH_AUTH_SOCK}" ]; then
                verbose "ERROR: unset SSH_AUTH_SOCK=${SSH_AUTH_SOCK}, socket not found writable\n"
                unset -v SSH_AUTH_SOCK
                if [ ${#SSH_AGENT_PID} -gt 0 ]; then
                    kill -9 ${SSH_AGENT_PID} &> /dev/null
                    unset -v SSH_AGENT_PID
                fi
            fi
        else
            # SSH_AUTH_SOCK is not a valid socket
            verbose "ERROR: unset SSH_AUTH_SOCK=${SSH_AUTH_SOCK}, socket not valid\n"
            unset -v SSH_AUTH_SOCK
            if [ ${#SSH_AGENT_PID} -gt 0 ]; then
                kill ${SSH_AGENT_PID} &> /dev/null
                unset -v SSH_AGENT_PID
            fi
        fi
    fi

    # remove old ssh_agent_sockets as safely as possible
    local ssh_agent_socket ssh_agent_socket_pid ssh_auth_sock
    ssh_auth_sock=$SSH_AUTH_SOCK
    while read ssh_agent_socket; do
        ssh_agent_socket_pid=''
        ssh_agent_socket_command=''

        if [ "${ssh_agent_socket}" == '' ] || [ ! -w "${ssh_agent_socket}" ]; then
            continue
        fi

        ssh_agent_socket_pid=${ssh_agent_socket##*.}
        if [[ ${ssh_agent_socket_pid} =~ ^[0-9]+$ ]]; then
            ssh_agent_socket_command=$(ps -h -o comm -p ${ssh_agent_socket_pid} 2> /dev/null)

            # TODO: test with gnome
            local ssh_agent_socket_identifier
            if [[ "${ssh_agent_socket_command}" == *'kde'* ]] || [[ "${ssh_agent_socket_command}" == *'plasma'* ]] || [ "${ssh_agent_socket_command}" == 'sshd' ]; then
                ssh_agent_socket_identifier=""
            else
                ((++ssh_agent_socket_pid))
                ssh_agent_socket_command=$(ps -h -o comm -p ${ssh_agent_socket_pid} 2> /dev/null)
                ssh_agent_socket_identifier=" [++]"
            fi
        fi

        # TODO: test with gnome
        if [[ "${ssh_agent_socket_command}" == *'kde'* ]] || [[ "${ssh_agent_socket_command}" == *'plasma'* ]] || [ "${ssh_agent_socket_command}" == 'sshd' ] || [ "${ssh_agent_socket_command}" == 'ssh-agent' ]; then
            # sometimes ssh-add fails to read the socket & takes 3+ minutes to timeout
            # if it takes longer than 5 seconds to read the socket then remove it (it's unusable)
            SSH_AUTH_SOCK=${ssh_agent_socket} timeout 5 ${Ssh_Add} -l ${ssh_agent_socket} &> /dev/null
            Ssh_Add_Rc=$?
            if [ ${Ssh_Add_Rc} -gt 1 ]; then
                # definite error
                verbose "ALERT: removing dead ssh_agent_socket ${ssh_agent_socket}, command=${ssh_agent_socket_command}, Ssh_Add_Rc=${Ssh_Add_Rc}"
                rm -f ${ssh_agent_socket} &> /dev/null
                Rm_Rc=$?
                if [ ${Rm_Rc} -ne 0 ]; then
                    verbose "ALERT: failed to 'rm -f ${ssh_agent_socket}', Rm_Rc=${Rm_Rc}"
                fi
                unset -v ssh_auth_sock
                unset -v Rm_Rc
            else
                # don't remove valid sockets; try to reuse them
                if [ ${#SSH_AGENT_PID} -eq 0 ] || [ ${#SSH_AUTH_SOCK} -eq 0 ]; then
                    if [ ${#SSH_AUTH_SOCK} -eq 0 ]; then
                        if [ ${#ssh_agent_socket_pid} -gt 0 ] && [ "${ssh_agent_socket_command}" == "ssh-agent" ]; then
                            export SSH_AGENT_PID=${ssh_agent_socket_pid}
                            verbose "DEBUG: reusing SSH_AGENT_PID=${SSH_AGENT_PID}" 18
                        fi

                        if [ ${#ssh_agent_socket} -gt 0 ]; then
                            export SSH_AUTH_SOCK=${ssh_agent_socket}
                            verbose "DEBUG: reusing SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" 18
                        fi
                    fi
                else
                    verbose "NOTICE: ssh_agent_socket_command = ${ssh_agent_socket_command} (pid=${ssh_agent_socket_pid})${ssh_agent_socket_identifier} [OK]" 3
                fi

                continue
            fi
            unset -v Ssh_Add_Rc
        else
            verbose "ALERT: removing unusable ssh_agent_socket ${ssh_agent_socket}, pid=${ssh_agent_socket_pid}, command=${ssh_agent_socket_command}"
            rm -f ${ssh_agent_socket} &> /dev/null
            Rm_Rc=$?
            if [ ${Rm_Rc} -ne 0 ]; then
                verbose "ALERT: failed to 'rm -f ${ssh_agent_socket}', Rm_Rc=${Rm_Rc}"
            fi
            unset -v ssh_auth_sock
            unset -v Rm_Rc
        fi
        verbose "ALERT: ssh_agent_socket_command = ${ssh_agent_socket_command} (pid=${ssh_agent_socket_pid})${ssh_agent_socket_identifier} [OK?]" # should be dead code
    done <<<"$(find /tmp/ssh* -type s -user ${User_Name} -wholename "*/ssh*agent*" 2> /dev/null)"

    unset -v ssh_agent_socket ssh_agent_socket_pid ssh_agent_socket_command ssh_auth_sock

    # remove old ssh_agent_pids as safely as possible
    local ssh_agent_pid ssh_agent_state_pid
    # don't kill the Ssh_Agent_State
    if [ -s "${Ssh_Agent_State}" ]; then
        ssh_agent_state_pid=$(grep "^SSH_AGENT_PID=" "${Ssh_Agent_State}" 2> /dev/null | awk -F\; '{print $1}' | awk -F= '{print $NF}')
    fi

    if [ ${#Ssh_Agent} -gt 0 ]; then
        if [ "${BD_OS}" == 'Darwin' ] || [ "${BD_OS,,}" == 'alpine' ]; then
            ssh_agent_pids=$(ps auxwww | grep "${USER}" | grep ${Ssh_Agent} | grep -v grep | awk '{print $2}')
        else
            ssh_agent_pids=$(pgrep -u "${USER}" -f ${Ssh_Agent} -P 1 2> /dev/null)
        fi

        for ssh_agent_pid in ${ssh_agent_pids}; do
            if [ ${#SSH_AGENT_PID} -gt 0 ]; then
                if [ "${ssh_agent_pid}" == "${SSH_AGENT_PID}" ]; then
                    # don't kill a running agent
                    continue
                fi
            fi

            if [ ${#ssh_agent_state_pid} -gt 0 ]; then
                if [ "${ssh_agent_pid}" == "${ssh_agent_state_pid}" ]; then
                    # don't kill a running agent
                    continue
                fi
            else
                if [ "${BD_OS}" != 'Darwin' ]; then
                    if [ ${#SSH_AGENT_PID} -gt 0 ]; then
                        if [ "${SSH_AGENT_PID}" == "${ssh_agent_pid}" ]; then
                            # don't kill the current agent
                            continue
                        fi
                    fi

                    verbose "ALERT: killing old ssh_agent_pid='${ssh_agent_pid}'"
                    kill ${ssh_agent_pid} &> /dev/null
                fi
            fi
        done
        unset -v ssh_agent_pid ssh_agent_state_pid
    fi

    # it's possible this condition could happen (again) if a socket's removed
    if [ ${#SSH_AGENT_PID} -gt 0 ] && [ ${#SSH_AUTH_SOCK} -eq 0 ]; then
        unset -v SSH_AGENT_PID
    fi

    if [ "${USER}" == "${Who}" ]; then
        if [ ${#SSH_AGENT_PID} -gt 0 ] && [ ${#SSH_AUTH_SOCK} -gt 0 ]; then
            verbose "DEBUG: creating ${Ssh_Agent_State}" 15
            printf "SSH_AUTH_SOCK=%s; export SSH_AUTH_SOCK;\n" "${SSH_AUTH_SOCK}" > "${Ssh_Agent_State}"
            printf "SSH_AGENT_PID=%s; export SSH_AGENT_PID;\n" "${SSH_AGENT_PID}" >> "${Ssh_Agent_State}"
            printf "echo Agent pid %s\n" "${SSH_AGENT_PID}" >> "${Ssh_Agent_State}"
        else
            if [ ${#SSH_AUTH_SOCK} -eq 0 ]; then
                verbose 'DEBUG: no SSH_AGENT_PID or SSH_AUTH_SOCK' 15
                if [ -f "${Ssh_Agent_State}" ]; then
                    verbose "DEBUG: removing ${Ssh_Agent_State}" 3
                    rm -f "${Ssh_Agent_State}" &> /dev/null
                    Rm_Rc=$?
                    if [ ${Rm_Rc} -ne 0 ]; then
                        verbose "ALERT: failed to 'rm -f ${Ssh_Agent_State}', Rm_Rc=${Rm_Rc}"
                    fi
                    unset -v Rm_Rc
                fi
            fi
        fi
    fi

    if [ -w "${Ssh_Agent_State}" ]; then
        chmod 0600 "${Ssh_Agent_State}" &> /dev/null
    fi
}

# export -f sshAgent
# export -f sshAgentInit
