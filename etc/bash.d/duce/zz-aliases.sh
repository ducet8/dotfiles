# vim: ft=sh
# 2023.10.05 - ducet8@outlook.com

##
# Opener Aliases
##
# Check for various OS openers. Quit as soon as we find one that works.
for opener in browser-exec xdg-open cmd.exe cygstart 'start' open; do
	if command -v $opener >/dev/null 2>&1; then
		if [[ "$opener" == 'cmd.exe' ]]; then
			# shellcheck disable=SC2139
			alias open="$opener /c start";
		else
			# shellcheck disable=SC2139
			alias open="$opener";
		fi
		break;
	fi
done
unset opener


##
# MacOS Specific Aliases
##
if [[ ${BD_OS,,} == 'darwin' ]]; then
    alias catpwd='cat ~/Desktop/password'
    alias cd='2cd'
    alias console='remote-viewer ~/Downloads/console.vv &'
    #alias cookbook='open ~/Documents/work/Docs/Cookbook/BCBSAL_Midrange_Cookbook.pdf'
    alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
    alias kitsune='~/projects/personal/kitsune/kitsune.py'
    alias password_cleanup='rm ~/Desktop/password'
    alias password_encode='openssl enc -a -des3 -in ~/Desktop/password >~/Documents/42.enc'
    alias password_decode='openssl enc -d -a -des3 -in ~/Documents/42.enc >~/Desktop/password'
    alias pubkey="cat ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
    alias release-camera='sudo killall VDCAssistant'
    alias showdesktop='defaults write com.apple.finder CreateDesktop -bool true && killfinder'
    alias hidedesktop='defaults write com.apple.finder CreateDesktop -bool false && killfinder'
fi


alias bell="echo -e '\a'"
alias binds="bind -P | grep 'can be'"
alias container_me="echo 'alias ll=\"ls -l\"; export PS1=\"\[\e[1;35m\]\w \[\e[1;33m\]$ \[\e[0m\]\"'"
alias container_ps1="echo 'export PS1=\"\[\e[1;35m\]\w \[\e[1;33m\]$ \[\e[0m\]\"'"


##
# cat Aliases
#
if type -P bat &>/dev/null; then
    alias cat='bat --paging=never --theme="gruvbox-dark"'
elif ([[ ${BD_OS_ID,,} == 'debian' ]] || [[ "${BD_OS_ID,,}" == 'ubuntu' ]]) && (type -P batcat &>/dev/null); then
    if [ ! -d "${HOME}/.local/bin" ]; then
        mkdir -p "${HOME}/.local/bin"
    fi
    if [ ! -L "${HOME}/.local/bin/bat" ]; then
        ln -s /usr/bin/batcat ~/.local/bin/bat
    fi
    if [[ "${PATH}" != *"${HOME}/.local/bin"* ]]; then
        export PATH=${PATH}:${HOME}/.local/bin
    fi
    alias cat='bat --paging=never --theme="gruvbox-dark"'
fi


#alias bluepip='python3 -m pip install --trusted-host blue-pip.apps.bcbsal.org --extra-index-url http://blue-pip.apps.bcbsal.org --upgrade'


##
# docker/podman Aliases
##
if type -P podman &>/dev/null; then
    alias docker=podman
fi
if type -P docker &>/dev/null || type -P podman &>/dev/null; then
    alias d='docker'
    alias dbt='docker build --tag'
    alias dp='docker push'
    alias powershell='docker run -it mcr.microsoft.com/powershell'
    alias rejson-serve='docker run -d -p 6379:6379 --name redis-redisjson redislabs/rejson:latest'
    alias vault-serve='docker run -d --name vault -p 8200:8200 -v ~/vault:/vault --cap-add=IPC_LOCK vault server && sleep 5 && docker exec vault /vault/startup.sh'
fi
alias foff='kill -9'


alias duh='export HISTSIZE=0; unset HISTSIZE; history -c'
alias edit='fc'


##
# git Aliases
##
if type -P git &>/dev/null; then
    alias .pull="git -C ${BD_HOME}/dotfiles/ pull --ff-only"
    alias ga='git add'
    alias gaa='git add --all'
    alias gcam='git commit -am'
    alias gco='git checkout'
    # alias ggpush="git push origin $(command git name-rev --name-only --no-undefined --always HEAD)"
    alias gl='git pull'
    alias glog='git log --pretty=format:"%an - %ar -- %h -- %s" --graph'
    alias gm='git merge'
    alias gp='git push'
    alias git-personal='git config user.name "Duce Tate" && git config user.email "ducet8@outlook.com"'
    alias gst='git status'
fi

alias grep='grep --color'

if type -P journalctl &>/dev/null; then
    alias jc='journalctl'
fi


##
# kubectl/oc Aliases
##
if type -P kubectl &>/dev/null; then
    alias kc='kubectl'
    alias false-claims='kubectl get managed -L crossplane.io/claim-name | grep cspire-com-3 | grep False'
fi
if type -P oc &>/dev/null; then
    alias oc-csr-approve='oc get csr -o name | xargs oc adm certificate approve'
    alias oc-vers='oc get pods | awk '\''{system("oc describe pod/"$1)}'\'' | grep Image:'
    alias okd-stats="oc describe nodes | grep -v 'cpu:\|memory:\|MemoryPressure' | grep 'cpu\|Name:\|memory'"
fi

alias list_functions='declare -F | awk '\''{print $3}'\'' | grep -v ^_'


##
# ls Aliases
##
if type -P lsd &>/dev/null; then
    if [ ! -d "${HOME}/.config/lsd" ]; then
        mkdir -p "${HOME}/.config/lsd"
    fi
    if [ ! -f "${HOME}/.config/lsd/config.yaml" ]; then
        echo "icons:" >"${HOME}/.config/lsd/config.yaml"
        echo "  when: never" >>"${HOME}/.config/lsd/config.yaml"
    fi
    alias la='lsd -lhaFv --group-directories-first'
    alias ll='lsd -lhFv --group-directories-first'
    alias ls='lsd -Fv --group-directories-first'
else
    # Detect which `ls` flavor is in use
    if ls --color &>/dev/null; then  # GNU `ls`
        colorflag='--color=auto'
    else  # OS X `ls`
        colorflag='-G'
    fi
    alias la="ls -lhaF ${colorflag}"
    alias ll="ls -lhF ${colorflag}"
    alias ls="ls -F ${colorflag}"
fi


##
# less Aliases
##
if type -P less &>/dev/null; then
    if type -P bat &>/dev/null; then
        alias less='bat --theme="gruvbox-dark"'
    elif [[ ${BD_OS,,} == 'debian' ]] && [ type -P batcat &>/dev/null ]; then
        if [ ! -d "${HOME}/.local/bin" ]; then
            mkdir -p "${HOME}/.local/bin"
        fi
        if [ ! -L "${HOME}/.local/bin/bat" ]; then
            ln -s /usr/bin/batcat ~/.local/bin/bat
        fi
        alias less='bat --theme="gruvbox-dark"'
    fi

    alias more='less'
fi


# alias pip3_upgrade_all="pip3 install --upgrade $(pip3 list | awk '{print $1}' | grep -v Package |grep -v \-)"
alias me="source ${BD_HOME}/.bash_profile"
alias myip='curl -s ipinfo.io | jq -r '\''.ip'\'

alias sal='ps -ef | grep [s]sh-agent; echo && env | grep -i ssh | sort -V; echo; ssh-add -l'
alias scpo='scp -o IdentitiesOnly=yes'
alias ssho='ssh -o IdentitiesOnly=yes'


if type -P systemctl &>/dev/null; then
    alias sc='systemctl'
fi
