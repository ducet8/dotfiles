# .bash_profile

Bash_Profile_Version="20220323, ducet8@outlook.com"

##
# Debugging with file descriptors and time
##
time_debug=1  # 0 is on/1 is off
if [[ ${time_debug} -eq 0 ]]; then
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

# No prompt
if [ ${#PS1} -le 0 ]; then return; fi

# SSH, No TTY,No TMUX
if [ ${#SSH_CONNECTION} -gt 0 ] && [ ${#SSH_TTY} -eq 0 ] && [ ${#TMUX} -eq 0 ]; then return; fi

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
            local git_ahead=$(printf -v int $(echo "${git_ahead_behind}" | awk -F\| '{print $1}'))
            local git_behind=$(printf -v int $(echo "${git_ahead_behind}" | awk -F\| '{print $2}'))
            if [[ "${git_ahead}" -lt "${git_behind}" ]]; then
                # need to pull
                elog notice "git_head_upstream = $(git -C "${dotdir}" rev-parse HEAD@{u} 2>/dev/null)"
                elog notice "git_head_working = $(git -C "${dotdir}" rev-parse HEAD 2>/dev/null)"

                git -C "${dotdir}" pull
            fi
        else
            elog alert "${dotdir} was not a git repository"
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
# Load the shell dotfiles
##
[[ -z "${SUDO_USER}" ]] && DOT_LOCATION="${HOME}" || DOT_LOCATION=$(cat /etc/passwd | grep -i "${SUDO_USER}" | cut -d: -f6)

for file in ${DOT_LOCATION}/.{exports,aliases,functions,bash_prompt}; do
    if [[ -r "${file}" ]] && [[ -f "${file}" ]]; then
        # shellcheck source=/dev/null
        source "${file}"
    fi
done
unset file

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
    if ! type -P ${tool} &>/dev/null; then
        if [[ ${tool} == "nvim" ]]; then tool="neovim"; fi
        missing_utils+="${tool} "
    fi
done
if [[ ${missing_utils} != "" ]]; then
    missing_util_msg="Missing Utilities: ${missing_utils}\n"
    if [[ ${Os_Id} == "macos" ]]; then
        missing_util_msg+="\tYou most likely need to run: brew install ${missing_utils}"
    elif [[ ${Os_Id} == "rocky" ]]; then
        # TODO: Fix this list as not all are available
        missing_util_msg+="\tYou most likely need to run: sudo dnf install ${missing_utils}"
    fi
    elog notice "${missing_util_msg}"
    unset missing_util_msg
fi
unset missing_utils
unset required_utils

printf "\n"
if [[ ${#Os_Pretty_Name} -gt 0 ]]; then
    elog -q info "${Os_Pretty_Name}\n"
else
    if [[ -r /etc/redhat-release ]]; then
        cat /etc/redhat-release
        printf "\n"
    fi
fi
elog -q info "${DOT_LOCATION}/.bash_profile: ${Bash_Profile_Version}\n"
