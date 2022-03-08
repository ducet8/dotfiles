# .bash_profile

Bash_Profile_Version="20220308, ducet8@outlook.com"

##
# Returns to Avoid Interactive Shell Enhancements
##
case $- in
    *i*)
        ;;          # interactive shell (OK)
    *)
        return ;;   # non-interactive shell
esac

# No prompt
if [ ${#PS1} -le 0 ]; then return; fi

# SSH, No TTY,No TMUX
if [ ${#SSH_CONNECTION} -gt 0 ] && [ ${#SSH_TTY} -eq 0 ] && [ ${#TMUX} -eq 0 ]; then return; fi

##
# Pull the latest dotfiles
##
update_dotfiles() {
    local dotowners=(duce rtate ducet8)
    if [[ (" ${dotowners[*]} " =~ " ${USER} ") && (-d ${HOME}/dotfiles) ]]; then
        local dotdir="${HOME}/dotfiles"
        local cwd=$(pwd 2>/dev/null)
        cd "${dotdir}" &>/dev/null

        if [ -d ${dotdir}/.git ]; then
            git fetch &> /dev/null

            local git_head_upstream=$(git rev-parse HEAD@{u} 2>/dev/null)
            local git_head_working=$(git rev-parse HEAD 2>/dev/null)

            if [ "${git_head_upstream}" != "${git_head_working}" ]; then
                # need to pull
                printf "NOTICE: git_head_upstream = ${git_head_upstream}"
                printf "NOTICE: git_head_working = ${git_head_working}\n"

                git pull
            fi
        else
            mkdir -p "${dotdir}"
            cd "${dotdir}" &>/dev/null
            git init
            git remote add origin git@github.com:ducet8/dotfiles
            git fetch
            git checkout -t origin/master -f
            git reset --hard
            git checkout -- .
        fi
        cd "${cwd}" &>/dev/null
    fi
}
update_dotfiles

##
# Load the shell dotfiles, and then some:
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
        if [ -r $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
            . $(brew --prefix)/etc/profile.d/bash_completion.sh
        elif [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        fi
   fi

   # Setup thefuck
   eval $(thefuck --alias)

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
required_utils=(bat git lsd nvim tmux vim wget)
missing_utils=""
for tool in $required_utils; do
    if ! type -P ${tool} &>/dev/null; then
        if [[ ${tool} == "nvim" ]]; then tool="neovim"; fi
        missing_utils+="${tool} "
    fi
done
if [[ ${missing_utils} != "" ]]; then
    printf "NOTICE: Missing Utilities: ${missing_utils}\n"
    if [[ ${Os_Id} == "macos" ]]; then
        printf "\tYou most likely need to run: brew install ${missing_utils}"
    elif [[ ${Os_Id} == "rocky" ]]; then
        printf "\tYou most likely need to run: sudo dnf install ${missing_utils}"
    fi
fi
unset missing_utils
unset required_utils

printf "\n"
if [ ${#Os_Pretty_Name} -gt 0 ]; then
    printf "${Os_Pretty_Name}\n\n"
else
    if [ -r /etc/redhat-release ]; then
        cat /etc/redhat-release
        printf "\n"
    fi
fi
printf "${DOT_LOCATION}/.bash_profile ${Bash_Profile_Version}\n\n"
