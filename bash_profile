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

# Source bash_completion
if [ -r $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
    # If you'd like to use existing homebrew v1 completions, add the following before the previous line:
    # export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
    . $(brew --prefix)/etc/profile.d/bash_completion.sh
fi

# Custom Settings
set -o vi		# Set vi as Editor

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Add tab completion for SSH hostnames based on ~/.ssh/config ignoring wildcards
[[ -e "$HOME/.ssh/config" ]] && complete -o "default" \
	-o "nospace" \
	-W "$(grep "^Host" ~/.ssh/config | \
	grep -v "[?*]" | cut -d " " -f2 | \
	tr ' ' '\n')" scp sftp ssh

# iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Setup thefuck
eval $(thefuck --alias)
