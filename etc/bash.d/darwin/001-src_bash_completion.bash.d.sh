#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

# Source bash_completion
if ! shopt -oq posix; then
    brew_prefix=$(brew --prefix)
    if [[ -r ${brew_prefix}/etc/profile.d/bash_completion.sh ]]; then
        source ${brew_prefix}/etc/profile.d/bash_completion.sh
    elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
    unset brew_prefix
fi