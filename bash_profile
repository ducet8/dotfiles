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
# Pull the latest dotfiles
##
update_dotfiles() {
    local dotowners=(duce dtate ducet8)
    dotdir="${HOME}/dotfiles"
    if [[ (" ${dotowners[*]} " =~ " ${USER} ") && (-d ${dotdir}) ]]; then
        export PATH=~/local/bin:$PATH
        if [ -d ${dotdir}/.git ]; then
            git -C "${dotdir}" fetch &> /dev/null

            local git_ahead_behind=$(git -C "${dotdir}" rev-list --left-right --count master...origin/master | tr -s '\t' '|';)
            local git_ahead=$(echo "${git_ahead_behind}" | awk -F\| '{print $1}')
            local git_behind=$(echo "${git_ahead_behind}" | awk -F\| '{print $2}')
            if [[ ${git_ahead} -lt ${git_behind} ]]; then
                export ELOG_GIT_MSG_LEVEL="notice"
                export ELOG_GIT_MSGS=(
                    "git_head_upstream = $(git -C "${dotdir}" rev-parse HEAD@{u} 2>/dev/null)"
                    "git_head_working = $(git -C "${dotdir}" rev-parse HEAD 2>/dev/null)"
                )

                git -C "${dotdir}" pull
            fi
        else
            export ELOG_GIT_MSG_LEVEL="alert"
            export ELOG_GIT_MSGS=(
                "${dotdir} was not a git repository"
            )
            local cwd=$(pwd 2>/dev/null)
            mkdir -p "${dotdir}"
            cd "${dotdir}" &>/dev/null
            git init
            git remote add origin git@github.com:ducet8/dotfiles
            git fetch
            git checkout -t origin/master -f
            git reset --hard
            git checkout -- .
            cd "${cwd}" &>/dev/null
        fi
    fi
}
update_dotfiles

##
# Mimic /etc/bash.d in ~/etc/bash.d
##
Etc_Dir=${BASH_SOURCE%/*}

if [ -r "${Etc_Dir}/etc/bash.d/000-bash.d.sh" ]; then
    source "${Etc_Dir}/etc/bash.d/000-bash.d.sh"
fi

if  [ ${#Etc_Dir} -gt 0 ] && [ "${Etc_Dir}" != "/" ] && [ -d "${Etc_Dir}/etc/bash.d" ]; then
    for Home_Etc_Bash_D_Sh in ${Etc_Dir}/etc/bash.d/*.sh; do
        if [ -r "${Home_Etc_Bash_D_Sh}" ]; then
            # echo "sourcing ${Home_Etc_Bash_D_Sh}"
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
# Print any git update messages
##
if [[ (-z ${ELOG_GIT_MSG_LEVEL}) && (-z ${ELOG_GIT_MSGS}) ]]; then
    for log_line in ${ELOG_GIT_MSGS}; do
        elog ${ELOG_GIT_MSG_LEVEL} "${log_line}"
    done
    unset ELOG_GIT_MSG_LEVEL
    unset ELOG_GIT_MSGS
fi

##
# Custom Settings
##
set -o vi               # Set vi as Editor
shopt -s histappend     # Append to the Bash history file, rather than overwriting it

##
# If OS is MacOS
##
if [[ ${Os_Id} == "macos" ]]; then
   # Source bash_completion
    if ! shopt -oq posix; then
        brew_prefix=$(brew --prefix)
        if [[ -r ${brew_prefix}/etc/profile.d/bash_completion.sh ]]; then
            . ${brew_prefix}/etc/profile.d/bash_completion.sh
        elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
            . /usr/share/bash-completion/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
            . /etc/bash_completion
        fi
        unset brew_prefix
   fi

   # Add tab completion for SSH hostnames based on ~/.ssh/config ignoring wildcards
   [[ -e "${DOT_LOCATION}/.ssh/config" ]] && complete -o "default" -o "nospace" \
      -W "$(grep "^Host" ~/.ssh/config | \
      grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" goto scp sftp ssh

   # iTerm2 Shell Integration
   test -e "${DOT_LOCATION}/.iterm2_shell_integration.bash" && source "${DOT_LOCATION}/.iterm2_shell_integration.bash"

fi

##
# Display some useful information
##
# Notify of missing utilities
required_utils=(bat git jq lsd nvim tmux vim wget)
missing_utils=""
for tool in $required_utils; do
    # echo ${tool}
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
