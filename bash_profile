# .bash_profile

Bash_Profile_Version="2022.08.03, ducet8@outlook.com"

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
# Mimic /etc/bash.d in ~/etc/bash.d
##
Etc_Dir=${BASH_SOURCE%/*}

# Pull the latest dotfiles
source "${Etc_Dir}/etc/bash.d/.update_dotfiles.bash.d.sh"
.update_dotfiles

if [ -r "${Etc_Dir}/etc/bash.d/000-bash.d.sh" ]; then
    source "${Etc_Dir}/etc/bash.d/000-bash.d.sh"
fi

if  [ ${#Etc_Dir} -gt 0 ] && [ "${Etc_Dir}" != "/" ] && [ -d "${Etc_Dir}/etc/bash.d" ]; then
    for Home_Etc_Bash_D_Sh in ${Etc_Dir}/etc/bash.d/*.sh; do
        if [ -r "${Home_Etc_Bash_D_Sh}" ]; then
            source "${Home_Etc_Bash_D_Sh}"
        fi
    done
    for Home_Etc_Bash_D_Sub in $(find ${Etc_Dir}/etc/bash.d/* -type d); do
        if [[ $(echo ${Home_Etc_Bash_D_Sub} | awk -F/ '{print tolower($NF)}') == ${Os_Id} ]]; then
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
unset Etc_Dir

##
# Custom Settings
##
set -o vi               # Set vi as Editor
shopt -s histappend     # Append to the Bash history file, rather than overwriting it

##
# Display some useful information
##
# Notify of missing utilities
required_utils=(bat git jq lsd nvim tmux vim wget)
missing_utils=""
for tool in $required_utils; do
    if ! type -P ${tool} &>/dev/null; then
        if [[ ${tool} == "nvim" ]]; then tool="neovim"; fi  # nvim is available as neovim
        if [[ ${tool} == "bat" ]] && [[ ${Os_Id} == "rocky" ]]; then continue; fi  # bat is not available on rocky
        missing_utils+="${tool} "
    fi
done
if [[ ${missing_utils} != "" ]]; then
    missing_util_msg="Missing Utilities: ${missing_utils}\n"
    if [[ ${Os_Id} == "macos" ]]; then
        missing_util_msg+="\tYou most likely need to run: brew install ${missing_utils}"
    elif [[ ${Os_Id} == "rocky" ]]; then
        missing_util_msg+="\tYou most likely need to run: sudo dnf install ${missing_utils}"
    fi
    elog notice "${missing_util_msg}"
    unset missing_util_msg
fi
unset missing_utils
unset required_utils

printf "\n"
if [[ ${#Os_Pretty_Name} -gt 0 ]]; then
    elog -q info "${Os_Pretty_Name^^}\n"
else
    if [[ -r /etc/redhat-release ]]; then
        cat /etc/redhat-release
        printf "\n"
    fi
fi
elog -q info "${DOT_LOCATION}/.bash_profile: ${Bash_Profile_Version}\n"
