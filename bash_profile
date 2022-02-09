# .bash_profile

Bashrc_Version="20220209, ducet8@outlook.com"

##
# Returns to Avoid Interactive Shell Enhancements
##
case $- in
    *i*)
        # interactive shell (OK)
        ;;
    *)
        # non-interactive shell
        return
        ;;
esac

if [ ${#PS1} -le 0 ]; then
    # no prompt
    return
fi

if [ ${#SSH_CONNECTION} -gt 0 ] && [ ${#SSH_TTY} -eq 0 ] && [ ${#TMUX} -eq 0 ]; then
    # ssh, no tty, no tmux
    return
fi

##
### Determine OS Variant
##
Os_Id=""
Os_Version_Id=""
Os_Version_Major=""
Os_Wsl=0

if uname -r | grep -q Microsoft; then
    Os_Wsl=1
fi

if [ -r /etc/os-release ]; then
    if [ ${#Os_Id} -eq 0 ]; then
        Os_Id=$(sed -nEe 's#"##g;s#^ID=(.*)$#\1#p' /etc/os-release)
    fi
    if [ ${#Os_Name} -eq 0 ]; then
        Os_Name=$(sed -nEe 's#"##g;s#^NAME=(.*)$#\1#p' /etc/os-release)
    fi
    if [ ${#Os_Pretty_Name} -eq 0 ]; then
        Os_Pretty_Name=$(sed -nEe 's#"##g;s#^PRETTY_NAME=(.*)$#\1#p' /etc/os-release)
        if [ ${Os_Wsl} -eq 1 ]; then
            Os_Pretty_Name+=" (WSL)"
        fi
    fi
    if [ ${#Os_Version_Id} -eq 0 ]; then
        Os_Version_Id=$(sed -nEe 's#"##g;s#^VERSION_ID=(.*)$#\1#p' /etc/os-release)
    fi
fi

if [ ${#Os_Id} -eq 0 ]; then
    if [ -r /etc/redhat-release ]; then
        Os_Id=rhel
        Os_Version_Id=$(sed 's/[^.0-9][^.0-9]*//g' /etc/redhat-release)
    fi
fi

if [ ${#Os_Id} -eq 0 ]; then
    if uname -s | grep -q Darwin; then
        Os_Id=macos
        Os_Version_Id=$(/usr/bin/sw_vers -productVersion 2> /dev/null)
    fi
fi

Os_Version_Major=${Os_Version_Id%.*}

export Os_Id Os_Version_Id Os_Version_Major Os_Wsl

if [ ${#Os_Id} -gt 0 ]; then
    if [ ${#Os_Version_Major} -gt 0 ]; then
        export Os_Variant="${Os_Id}/${Os_Version_Major}"
    else
        export Os_Variant="${Os_Id}"
    fi
fi

export Uname_I=$(uname -i 2> /dev/null)

##
# Load the shell dotfiles, and then some:
##
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{aliases,functions,path,dockerfunc,extra,exports,bash_prompt}; do
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

##
# Append to the Bash history file, rather than overwriting it
##
shopt -s histappend

##
# If OS is MacOS
##
if [[ ${Os_Id} == "macos" ]]; then
   # Source bash_completion
   if [ -r $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
      # If you'd like to use existing homebrew v1 completions, add the following before the previous line:
      # export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
      . $(brew --prefix)/etc/profile.d/bash_completion.sh
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
