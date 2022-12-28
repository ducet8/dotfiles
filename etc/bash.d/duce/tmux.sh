# Forked from: joseph.tingiris@gmail.com
# 2022.12.21 - ducet8@outlook.com

# Set tmux info

if [ ${#TMUX} -gt 0 ]; then
    if type -P fzf-tmux &> /dev/null; then
        alias fzf=fzf-tmux
    fi
fi

if [ ${#TMUX} -gt 0 ]; then
    # already in a tmux
    if [ "${BD_OS}" == 'linux' ]; then
        export TMUX_BIN=$(ps -ho cmd -p $(ps -ho ppid -p $$ 2> /dev/null) 2> /dev/null | awk '{print $1}')
    fi
    if [ "${BD_OS}" == 'darwin' ]; then
        export TMUX_BIN=$(which $(ps -o command -p $(ps -o ppid -p $$ | sed 1d 2>/dev/null) | sed 1d 2>/dev/null) | awk '{print $1}')
    fi

    TMUX_SESSION_NAME_COUNT=1
    TMUX_SESSION_NAME="$(${TMUX_BIN} display-message -p '#S')"
    if [[ ${TMUX_SESSION_NAME} =~ ^[0-9]+$ ]]; then
        while ${TMUX_BIN} has-session -t "${TMUX_SESSION_NAME}" &> /dev/null; do
            #TMUX_SESSION_NAME="${PWD##*/} - ${TMUX_SESSION_NAME_COUNT}"
            TMUX_SESSION_NAME="${PWD} - ${TMUX_SESSION_NAME_COUNT}"
            let TMUX_SESSION_NAME_COUNT=${TMUX_SESSION_NAME_COUNT}+1
        done
        bd_ansi reset && bd_ansi fg_red1 && echo "${TMUX_BIN} rename-session \"${TMUX_SESSION_NAME}\"" && bd_ansi reset
        ${TMUX_BIN} rename-session "${TMUX_SESSION_NAME}"
    fi
    TMUX_SESSION_NAME="$(${TMUX_BIN} display-message -p '#S')"
else
    # not in in a tmux
    export TMUX_BIN="$(type -P tmux 2> /dev/null)"
fi

if [ ${#TMUX_BIN} -gt 0 ] && [ -x ${TMUX_BIN} ]; then
    if [ -z ${TMUX_VERSION} ]; then
        export TMUX_VERSION="$(${TMUX_BIN} -V 2> /dev/null)"
        TMUX_VERSION=${TMUX_VERSION##* }
    else
        export TMUX_VERSION=${TMUX_VERSION}
    fi
    TMUX_INFO="    binary:\t${TMUX_BIN} v${TMUX_VERSION}\n"
    if [ -n "${TMUX_SESSION_NAME}" ]; then
        TMUX_INFO+="    session:\t${TMUX_SESSION_NAME}\n"
    fi
    if [ -r "${BD_HOME}/.tmux.conf" ]; then
        TMUX_INFO+="    conf:\t${BD_HOME}/.tmux.conf\n"
        #alias t='tmux at || tmux' # this doesn't work right, attach or start a new one fails in certain use cases when exiting a running session
        alias t='tmux at'
        alias tls='tmux ls'
        alias tmux="unset BASHRCSOURCED BD_ID && ${TMUX_BIN} -f ${BD_HOME}/.tmux.conf -u"
    fi
else
    unset TMUX_BIN
fi

