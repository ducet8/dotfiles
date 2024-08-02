# vim: ft=sh
# 2024.08.02 - ducet8@outlook.com

##
# Bash Exports
##
if [[ ${BD_OS,,} == "darwin" ]]; then
    export SHELL=/usr/local/bin/bash  # Brew's bash
    export BASH_SILENCE_DEPRECATION_WARNING=1  # hide macos' 'default shell is now ZSH message on root login'
else
    export SHELL=$(which bash)
fi


##
# bd exports
##
if type bd_ansi &>/dev/null; then
    export -f bd_ansi
fi


##
# Brew Exports
##
if [[ ${BD_OS,,} == "darwin" ]]; then
    export HOMEBREW_NO_ANALYTICS=1  # Disable homebrew analytics
fi


##
# Colors for ls Exports
##
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'


##
# EDITOR Exports
##
unset -v EDITOR
Editors=(nvim vim vi)
for Editor in ${Editors[@]}; do
    if type -P ${Editor} &> /dev/null; then
        export EDITOR="$(type -P ${Editor} 2> /dev/null)"
        if [[ "${EDITOR}" == *"vim"* ]] && [ -r "${BD_HOME}/.vimrc" ]; then
            alias vim="HOME=\"${BD_HOME}\" ${EDITOR} --cmd \"let BD_USER='$(whoami)'\" --cmd \"let BD_HOME='${BD_HOME}'\""
        else
            alias vim="${EDITOR}"
        fi
        if type -P vim &> /dev/null; then
            alias vi=vim
        fi
        break
    fi
done
unset -v Editor Editors

##
# Git Exports
##
if type -P git &> /dev/null; then
    export GIT_EDITOR=${EDITOR}
fi

##
# Go Exports
##
if [[ ${BD_OS,,} == "darwin" ]]; then
    export SHELL=/usr/local/bin/bash
    export GOPATH=${HOME}/projects/go
    export GOROOT=/usr/local/opt/go/libexec
    export PATH=${PATH}:${GOROOT}/bin
else
    export GOPATH=${HOME}/go
fi
export GOBIN=${GOPATH}/bin
export PATH=${PATH}:${GOPATH}/bin

# if it's an ssh session export GPG_TTY
if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_TTY}" ]]; then
	GPG_TTY=$(tty)
	export GPG_TTY
fi

# hidpi for gtk apps
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_DEVICE_PIXEL_RATIO=2

##
# History Exports
##
export HISTSIZE=50000000;
export HISTFILESIZE=${HISTSIZE};
export HISTIGNORE=" *:ls:cd:cd -:cd ~:pwd:exit:date:* --help:* -h:clear:man *:df -*:history *";
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "

export TZ="America/Chicago"

##
# Language Exports - Prefer US English and use UTF-8
##
#export LANG="en_US.UTF-8";
#if [[ ${BD_OS,,} == "darwin" ]]; then
#    export LC_ALL="en_US.UTF-8";
#fi
export LC_COLLATE=POSIX

##
# Man Exports
##
if type -P bat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
    # Don’t clear the screen after quitting a manual page
    export MANPAGER="less -X";
fi
Man_Paths=()
Man_Paths+=(/usr/local/share/man)
Man_Paths+=(/usr/share/man)
for Man_Path in ${Man_Paths[@]}; do
    if ! [[ "${MANPATH}" =~ (^|:)${Man_Path}($|:) ]]; then
        if [ -r "${Man_Path}" ]; then
            export MANPATH+=":${Man_Path}"
        fi
    fi
done

export TODOTXT_DEFAULT_ACTION=ls

##
# Python Exports
##
if [[ ${BD_OS,,} == "darwin" ]]; then
    export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
fi

##
# Subversion Exports
##
if type -P svn &> /dev/null; then
    export SVN_EDITOR=${EDITOR}
fi

##
# TERM Exports (preserve TERM for screen & tmux; handle TERM before prompt)
##
if [ "${TERM}" != "linux" ] && [[ "${TERM}" != *"screen"* ]] && [[ "${TERM}" != *"tmux"* ]]; then
    if [ ${#KONSOLE_DBUS_WINDOW} -gt 0 ] && [ -r /usr/share/terminfo/k/konsole-256color ]; then
        export TERM=konsole-256color # if it's a konsole dbus window then use konsole-256color
    else
        export TERM=xterm-256color
    fi
fi

if [[ "${TERM}" == *"screen"* ]]; then
    if [ -r /usr/share/terminfo/s/screen-256color ] || [ -r /usr/share/terminfo/73/screen-256color ] || [ -r /usr/lib/terminfo/s/screen-256color ]; then
        export TERM=screen-256color
    else
        if [ -r /usr/share/terminfo/s/screen ]; then
            export TERM=screen
        else
            export TERM=ansi
        fi
    fi
fi

# This is mainly for performance; as long as TERM doesn't change then there's no need to run tput every time
if [ "${TERM}" != "${TPUT_TERM}" ] || [ ${#TPUT_TERM} -eq 0 ]; then
    if type -P tput &> /dev/null; then
        export TPUT_TERM=${TERM}
        export TPUT_BOLD="$(tput bold 2> /dev/null)"
    fi
fi

##
# Uname Exports
##
export Uname_I=$(uname -i 2> /dev/null)

##
# Weather (WTTR) Exports
##
export WTTR_PARAMS=Fu
export WTTR_LOCATION=35209

##
# Work Exports
##
export LD_AZURE_DEV_SUB_ID="f60babca-e1aa-4d01-9b4e-8c0ece828a1a"
export LD_AZURE_PROD_SUB_ID="efe25833-7fd6-4958-af0e-520f85156d10"

##
# Local Exports
##
if  [[ -r ${HOME}/exports_local ]] && [[ -f ${HOME}/exports_local ]]; then
    source ${HOME}/exports_local
fi
