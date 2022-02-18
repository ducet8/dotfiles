# .bash_profile

Bash_Profile_Version="20220218, ducet8@outlook.com"

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
# Load the shell dotfiles, and then some:
##
[[ -z "${SUDO_USER}" ]] && DOT_LOC=$(cat /etc/passwd | grep -i "${SUDO_USER}" | cut -d: -f6) || DOT_LOC="~"

for file in ${DOT_LOC}/.{exports,aliases,functions,bash_prompt}; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
        # shellcheck source=/dev/null
        source "$file"
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
   [[ -e "$HOME/.ssh/config" ]] && complete -o "default" -o "nospace" \
      -W "$(grep "^Host" ~/.ssh/config | \
      grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" goto scp sftp ssh

   # iTerm2 Shell Integration
   test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

fi

printf "${HOME}/.bash_profile ${Bash_Profile_Version}\n\n"
