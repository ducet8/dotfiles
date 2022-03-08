# .bash_profile

Bash_Profile_Version="20220308, ducet8@outlook.com"

# TODO: Add an init that checks for common tools that are missing and provides the appropriate install command on login

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
DOTOWNERS=(duce rtate ducet8)
if [[ (" ${users[*]} " =~ " ${USER} ") && (-d ${HOME}/dotfiles) ]]; then
    git -qC ${HOME}/dotfiles pull
fi
unset DOTOWNERS

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
