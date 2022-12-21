# 2022.12.21 - ducet8@outlook.com

if [[ ${BD_OS,,} == "darwin" ]]; then
    # Source bash_completion
    if ! shopt -oq posix; then
        if type -P brew &> /dev/null; then
            brew_prefix=$(brew --prefix)
            if [[ -r ${brew_prefix}/etc/profile.d/bash_completion.sh ]]; then
                source ${brew_prefix}/etc/profile.d/bash_completion.sh
            elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
                source /usr/share/bash-completion/bash_completion
            elif [[ -f /etc/bash_completion ]]; then
                source /etc/bash_completion
            fi
            unset brew_prefix
          else
            bd_ansi reset; bd_ansi fg_yellow4
            echo "brew NOT found! bash_completion.sh NOT sourced!"
            bd_ansi reset
        fi
    fi
fi
