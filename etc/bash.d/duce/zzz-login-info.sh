# 2023.02.18 - ducet8@outlook.com

# Display some useful information

# Display OS Info
if [[ ${#BD_OS_PRETTY_NAME} -gt 0 ]]; then
    bd_ansi reset; bd_ansi fg_cyan2
    printf "${BD_OS_PRETTY_NAME^^}\n\n"
fi


# Display Profile Version
bd_ansi reset; bd_ansi fg_cyan4
printf "${BD_HOME}/.bash_profile:"
bd_ansi reset; bd_ansi fg_cyan2
printf "\t${BASH_PROFILE_VERSION}\n\n"

if [[ ${BD_MISSING_UTIL_CHECK} != 1 ]]; then
    # Notify of missing utilities
    required_utils=(bat git jq lsd nvim tmux vim wget)
    missing_utils=''
    unavailable_utils=''
    for tool in $required_utils; do
        if ! type -P "${tool}" &>/dev/null; then
            if [[ "${tool}" == 'nvim' ]]; then tool='neovim'; fi  # nvim is available as neovim
            if [[ "${tool}" == 'bat' ]]; then
                if [[ "${BD_OS_ID,,}" == 'centos' ]] || [[ "${BD_OS_ID,,}" == 'rhel' ]] || [[ "${BD_OS_ID,,}" =~ 'rocky' ]]; then 
                    unavailable_utils+="${tool} "
                    continue  # bat is not available on rocky or centos
                elif [[ "${BD_OS_ID,,}" == 'debian' ]] && (! type -P batcat &>/dev/null); then
                    tool='batcat'  # batcat is used on debian
                fi
            fi
            missing_utils+="${tool} "
        fi
    done
    if [[ ${missing_utils} != '' ]] || [[ ${unavailable_utils} != '' ]]; then
        bd_ansi reset; bd_ansi fg_yellow3
        printf "Missing Utilities: ${missing_utils}\n"
    fi
    if [[ ${unavailable_utils} != '' ]]; then
        printf "\tNot available on ${BD_OS_ID^}: ${unavailable_utils}\n\n"
        unset unavailable_utils
    fi
    if [[ ${missing_utils} != '' ]]; then
        if [[ "${BD_OS,,}" == 'darwin' ]]; then
            os_msg='run: brew '
        elif [[ "${BD_OS_ID,,}" == 'rocky' ]] || [[ "${BD_OS_ID,,}" =~ 'centos' ]]; then
            os_msg='run: sudo dnf '
        elif [[ "${BD_OS,,}" == 'debian' ]]; then
            os_msg='run: sudo apt '
        fi
        missing_util_msg+="\tYou most likely need to ${os_msg}install ${missing_utils}\n\n"
        printf "${missing_util_msg}"
        bd_ansi reset
        unset missing_util_msg os_msg
    fi
    unset missing_utils required_utils
    export BD_MISSING_UTIL_CHECK=1
fi


# Display ssh-agent information
bd_ansi reset && bd_ansi fg_cyan4 
printf "SSH-AGENT:\t\t\t"
if ssh-add -l &> /dev/null; then 
    bd_ansi reset && bd_ansi fg_cyan2
    printf "$(ssh-add -l | wc -l | awk '{print $1}')\n"
else
    bd_ansi reset && bd_ansi fg_red1 
    printf "ERROR\n"
fi


# Display DISPLAY if set
bd_ansi reset && bd_ansi fg_cyan4 
[ ! -z "${DISPLAY}" ] && printf "DISPLAY:\t\t\t"; bd_ansi reset && bd_ansi fg_cyan2 && printf "${DISPLAY}\n"


# Dsiplay any tmux info
bd_ansi reset && bd_ansi fg_cyan4
if [ "${TMUX}" ]; then
    tmux_fmt="\t$(bd_ansi reset && bd_ansi fg_cyan4)%-24s$(bd_ansi reset && bd_ansi fg_cyan2)%-12s\n"
    printf "TMUX:\n"
    printf "${tmux_fmt}" "binary:" "${TMUX_BIN}"
    printf "${tmux_fmt}" "session:" "${TMUX_SESSION_NAME}"
    printf "${tmux_fmt}" "conf:" "${TMUX_COMMAND}"
    printf "${tmux_fmt}" "socket:" "${BD_HOME}/.tmux.conf"
    bd_ansi reset
    unset tmux_fmt
fi


bd_ansi reset
