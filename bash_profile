# .bash_profile

Bash_Profile_Version="2022.08.10, ducet8@outlook.com"


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

export Verbose=8


##
# Mimic /etc/bash.d in ~/etc/bash.d
##
User_Dir=${BASH_SOURCE%/*}

if [ -r "${User_Dir}/etc/bash.d/000-bash.d.sh" ]; then
    source "${User_Dir}/etc/bash.d/000-bash.d.sh"
fi

if  [ ${#User_Dir} -gt 0 ] && [ "${User_Dir}" != "/" ] && [ -d "${User_Dir}/etc/bash.d" ]; then
    for Home_Etc_Bash_D_Sh in ${User_Dir}/etc/bash.d/*.sh; do
        if [ -r "${Home_Etc_Bash_D_Sh}" ]; then
            source "${Home_Etc_Bash_D_Sh}"
        fi
    done
    for Home_Etc_Bash_D_Sub in $(find ${User_Dir}/etc/bash.d/* -type d); do
        if [[ $(echo ${Home_Etc_Bash_D_Sub} | awk -F/ '{print tolower($NF)}') == ${Os_Id,,} ]]; then
            for Home_Etc_Bash_D_Sh in ${Home_Etc_Bash_D_Sub}/*.sh; do
                if [ -r "${Home_Etc_Bash_D_Sh}" ]; then
                    source "${Home_Etc_Bash_D_Sh}"
                fi
            done
            unset -v Home_Etc_Bash_D_Sub
        fi
    done
    unset -v Home_Etc_Bash_D_Sh
fi
unset Home_Etc_Bash_D_Sh


##
# Custom Settings
##
set -o vi               # Set vi as Editor
shopt -s histappend     # Append to the Bash history file, rather than overwriting it
shopt -s checkwinsize   # Check the window size after each command. If necessary, update the values of LINES and COLUMNS.


##
# Trap EXIT; ensure .bash_logout gets called, regardless
##
if  [ "$(type -t verbose)" == "function" ]; then
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


##
# Display some useful information
##
[ ! -z ${Verbose} ] && verbose "NOTICE: Verbose=${Verbose}"

verbose "DEBUG: USER='${USER}'" 14
verbose "DEBUG: Who='${Who}'" 12
verbose "DEBUG: User_Dir=${User_Dir}" 12

# Notify of missing utilities
required_utils=(bat git jq lsd nvim tmux vim wget)
missing_utils=""
for tool in $required_utils; do
    if ! type -P ${tool} &>/dev/null; then
        if [[ ${tool} == "nvim" ]]; then tool="neovim"; fi  # nvim is available as neovim
        if [[ ${tool} == "bat" ]] && ([[ ${Os_Id,,} == "rocky" ]] || [[ ${Os_Id,,} =~ "centos" ]]); then continue; fi  # bat is not available on rocky
        missing_utils+="${tool} "
    fi
done
if [[ ${missing_utils} != "" ]]; then
    missing_util_msg="Missing Utilities: ${missing_utils}\n"
    if [[ ${Os_Id,,} == "darwin" ]]; then
        missing_util_msg+="\tYou most likely need to run: brew install ${missing_utils}"
    elif [[ ${Os_Id,,} == "rocky" ]] || [[ ${Os_Id,,} =~ "centos" ]]; then
        missing_util_msg+="\tYou most likely need to run: sudo dnf install ${missing_utils}"
    fi
    verbose "${missing_util_msg}" 5
    unset missing_util_msg
fi
unset missing_utils
unset required_utils

printf "\n"
if [[ ${#Os_Pretty_Name} -gt 0 ]]; then
    printf "${YELLOW}${Os_Pretty_Name^^}${RESET}\n"
    # verbose "INFO: ${Os_Pretty_Name^^}\n"
else
    if [[ -r /etc/redhat-release ]]; then
        cat /etc/redhat-release
        printf "\n"
    fi
fi

printf "${YELLOW}${DOT_LOCATION}/.bash_profile: ${Bash_Profile_Version}${RESET}\n"
# verbose "INFO: ${DOT_LOCATION}/.bash_profile = ${Bash_Profile_Version}"

[ ! -z "${DISPLAY}" ] && echo ""; verbose "INFO: DISPLAY = ${DISPLAY}"

if [ "${TMUX}" ]; then
    verbose "${Tmux_Info} [${TMUX}]\n" 8
fi

unset Verbose
