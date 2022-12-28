# 2022.12.27 - ducet8@outlook.com

# Display some useful information

# Display OS Info
bd_ansi reset; bd_ansi fg_yellow4
if [[ ${#BD_OS_PRETTY_NAME} -gt 0 ]]; then
    echo "${BD_OS_PRETTY_NAME^^}" && echo ''
fi

# Display Profile Version
bd_ansi reset; bd_ansi fg_yellow4
echo "${BD_HOME}/.bash_profile: ${BASH_PROFILE_VERSION}" && echo ''

if [[ ${BD_MISSING_UTIL_CHECK} != 1 ]]; then
    # Notify of missing utilities
    required_utils=(bat git jq lsd nvim tmux vim wget)
    missing_utils=''
    unavailable_utils=''
    for tool in $required_utils; do
        if ! type -P "${tool}" &>/dev/null; then
            if [[ "${tool}" == 'nvim' ]]; then tool='neovim'; fi  # nvim is available as neovim
            if [[ "${tool}" == 'bat' ]]; then
                if [[ "${BD_OS_ID,,}" == 'rocky' ]] || [[ "${BD_OS_ID,,}" =~ 'centos' ]]; then 
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
        bd_ansi reset; bd_ansi fg_yellow5
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
        missing_util_msg+="\tYou most likely need to ${os_msg}install ${missing_utils}"
        printf "${missing_util_msg}"
        bd_ansi reset
        unset missing_util_msg os_msg
    fi
    unset missing_utils required_utils
    export BD_MISSING_UTIL_CHECK=1
fi

# Display DISPLAY if set
[ ! -z "${DISPLAY}" ] && bd_ansi reset && bd_ansi fg_magenta4 && printf "DISPLAY: \t${DISPLAY}\n"

# Dsiplay any tmux info
if [ "${TMUX}" ]; then
    bd_ansi reset; bd_ansi fg_magenta4
    printf "TMUX:\n${TMUX_INFO}    socket:\t${TMUX}\n"
    bd_ansi reset
fi
