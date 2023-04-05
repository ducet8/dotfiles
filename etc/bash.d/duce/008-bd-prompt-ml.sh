# Forked from: joseph.tingiris@gmail.com
# 2023.03.27 - ducet8@outlook.com

##
### machine learning prompt 0.1
##

function bash_prompt() {
    #echo "${FUNCNAME}()"

    local bash_prompt_color_term=0 # faster than case every time

    # set window title; TODO check terms that support this
    case "${TERM}" in
        alacritty*|ansi*|*color|screen*|*tmux*|*xterm*)
            # enable ansi sequences PS1
            bash_prompt_color_term=1

            local bash_prompt_window_title=''
            bash_prompt_window_title+="${USER}@"
            bash_prompt_window_title+="${HOSTNAME}"
            bash_prompt_window_title+=":${PWD}"

            echo -ne "\e]0;${bash_prompt_window_title}\a" # e = 033 (ESC), a = 007 (BEL)
            ;;
        *)
            echo "TERM=${TERM}"
            echo
            ;;
    esac

    # this space reserved for before prompt ...

    # construct dynamic PS1
    local bash_prompt_ps1=''

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        bash_prompt_ps1+="\[$(bd_ansi reset)\]"
        bash_prompt_ps1+="\[$(bd_ansi bold)\]"
        bash_prompt_ps1+="\[$(bash_prompt_color 2)\]"
    fi

    bash_prompt_ps1+='['

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        bash_prompt_ps1+="\[$(bash_prompt_color 3)\]"
    fi

    bash_prompt_ps1+="\u"

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        # bash_prompt_ps1+="\[$(bash_prompt_color 2)\]"
        bash_prompt_ps1+="\[$(bd_ansi fg_gray2)\]"
    fi

    bash_prompt_ps1+='@'

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        # bash_prompt_ps1+="\[$(bash_prompt_color 3)\]"
        [ -z ${SSH_TTY} ] && bash_prompt_ps1+="\[$(bd_ansi fg_gray3)\]" || bash_prompt_ps1+="\[$(bd_ansi fg_green3)\]"
    fi

    bash_prompt_ps1+="\H"

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        bash_prompt_ps1+="\[$(bash_prompt_color 1)\]"
    fi

    bash_prompt_ps1+=" \w"

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        bash_prompt_ps1+="\[$(bash_prompt_color 2)\]"
    fi

    bash_prompt_ps1+=']'

    local bash_prompt_glyphs=''

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        bash_prompt_ps1+="\[$(bd_ansi reset)\]"
    fi

    # glyph: git is detected; do what?
    if [ -d .git ]; then
        #bash_prompt_glyphs+='♬ '
        bash_prompt_glyphs+='♪'
    fi

    # glyph: etc/bash.d is detected; add a symbol
    if [ "${BD_ID}" != "" ] && [ -d etc/bash.d ]; then
        bash_prompt_glyphs+='♭'
    fi

    [ ${#bash_prompt_glyphs} -gt 0 ] && bash_prompt_ps1+="${bash_prompt_glyphs}"

    # append colored/utf-8 symbols for # and $
    if [ ${bash_prompt_color_term} -eq 1 ]; then
        bash_prompt_ps1+="\[$(bash_prompt_color 1)\]"
    fi

    [ "${USER}" == 'root' ] && bash_prompt_ps1+='♯' || bash_prompt_ps1+='$'

    # single symbols that are multibyte tend to have some additional visible space & an extra space is subjective
    bash_prompt_ps1+=' '

    [ ${bash_prompt_color_term} -eq 1 ] && bash_prompt_ps1+="\[$(bd_ansi reset)\]"

    # set the promp
    PS1="${bash_prompt_ps1}"

    unset -v bash_prompt_color_term bash_prompt_window_title bash_prompt_ps1
}

function bash_prompt_color() {
    local bash_prompt_color_name

    # allow setting via ~/.bash-prompt_color
    [ -r ~/.bash_prompt_color ] &&  bash_prompt_color_name="$(egrep -m 1 -e '^black$|^red$|^green$|^yellow$|^blue$|^magenta$|^cyan$|^white$|^gray$|^grey$' ~/.bash_prompt_color)"

    # allow alternate setting with a global
    [ -z "${bash_prompt_color_name}" ] && bash_prompt_color_name="${BD_PROMPT_COLOR}" # must match a valid color, exactly, or it will be white

    if [ "${USER}" == "${PROMPT_LOGNAME}" ]; then
        [ -z "${bash_prompt_color_name}" ] && bash_prompt_color_name="green"
        bd_ansi fg_${bash_prompt_color_name}${1}
    else
        case ${USER} in
            root)
                bash_prompt_color_name="yellow" # root is always yellow
                bd_ansi fg_${bash_prompt_color_name}${1}
                ;;
            *)
                [ -z "${bash_prompt_color_name}" ] && bash_prompt_color_name="gray"
                bd_ansi fg_${bash_prompt_color_name}${1}
                ;;
        esac
    fi
}

if [ "${BD_OS}" != 'darwin' ]; then
    PROMPT_LOGNAME=$(logname 2> /dev/null)
fi
[ ${#PROMPT_LOGNAME} -eq 0 ] && PROMPT_LOGNAME="${USER}"

PROMPT_COMMAND='bash_prompt'
