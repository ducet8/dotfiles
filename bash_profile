# .bash_profile

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{aliases,functions,path,dockerfunc,extra,exports,bash_prompt}; do
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
done
unset file

# Custom Settings
set -o vi               # Set vi as Editor

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# If OS is MacOS
if [[ `uname` == "Darwin" ]]; then
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
    grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

  # iTerm2 Shell Integration
  test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

   # Setting PATH for Python 3.10
   PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:${PATH}"
   export PATH

fi
