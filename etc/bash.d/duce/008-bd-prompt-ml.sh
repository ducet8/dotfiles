# Forked from: joseph.tingiris@gmail.com
# 2022.11.09 - ducet8@outlook.com

##
### machine learning prompt 0.1
##

function bash_prompt() {
    #echo "${FUNCNAME}()"

    local bash_prompt_color_term=0 # faster than case every time

    # set window title; TODO check terms that support this
    case "${TERM}" in
        ansi|*color|screen*|*tmux*|*xterm*)
            # enable ansi sequences PS1
            bash_prompt_color_term=1

            local bash_prompt_window_title=''
            bash_prompt_window_title+="${USER}@"
            bash_prompt_window_title+="${HOSTNAME}"
            bash_prompt_window_title+=":${PWD}"

            echo -ne "\033]0;${bash_prompt_window_title}\007"
            ;;
        *)
            echo "TERM=${TERM}"
            echo
            ;;
    esac

    # this space reserved for before prompt ...

    # construct dynamic PS1
    local bash_prompt_color='' bash_prompt_ps1=''
    if [ ${bash_prompt_color_term} -eq 1 ]; then
        bash_prompt_ps1+="\[$(bd_ansi reset)\]"
        bash_prompt_ps1+="\[$(bd_ansi bold)\]"

        # bash_prompt_ps1+="\[$(bd_ansi bg_black)\]"

        if [ "${USER}" == 'root' ]; then
            bash_prompt_color="$(bd_ansi fg_yellow4)"
        else
            bash_prompt_color="$(bd_ansi fg_green4)" || bash_prompt_color="$(bd_ansi fg_gray4)"
        fi
        bash_prompt_ps1+="\[${bash_prompt_color}\]"
    fi
    bash_prompt_ps1+='❲'

    bash_prompt_ps1+="\u"

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        if [ "${USER}" == 'root' ]; then
            bash_prompt_color="$(bd_ansi fg_yellow3)"
        else
            [ "${USER}" == 'duce' ] && bash_prompt_color="$(bd_ansi fg_green3)" || bash_prompt_color="$(bd_ansi fg_gray3)"
        fi
        bash_prompt_ps1+="\[${bash_prompt_color}\]"
    fi
    bash_prompt_ps1+='@'

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        if [ "${USER}" == 'root' ]; then
            bash_prompt_color="$(bd_ansi fg_yellow4)"
        else
            [ "${USER}" == 'duce' ] && bash_prompt_color="$(bd_ansi fg_green4)" || bash_prompt_color="$(bd_ansi fg_gray4)"
        fi
        bash_prompt_ps1+="\[${bash_prompt_color}\]"
    fi
    bash_prompt_ps1+="\H"

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        if [ "${USER}" == 'root' ]; then
            bash_prompt_color="$(bd_ansi fg_yellow1)"
        else
            [ "${USER}" == 'dtate' ] && bash_prompt_color="$(bd_ansi fg_green1)" || bash_prompt_color="$(bd_ansi fg_gray1)"
        fi
        bash_prompt_ps1+="\[${bash_prompt_color}\]"
    fi
    bash_prompt_ps1+=" \w"

    if [ ${bash_prompt_color_term} -eq 1 ]; then
        if [ "${USER}" == 'root' ]; then
            bash_prompt_color="$(bd_ansi fg_yellow4)"
        else
            [ "${USER}" == 'duce' ] && bash_prompt_color="$(bd_ansi fg_green4)" || bash_prompt_color="$(bd_ansi fg_gray4)"
        fi
        bash_prompt_ps1+="\[${bash_prompt_color}\]"
    fi
    bash_prompt_ps1+='❳'

    # reset for all glyphs
    [ ${bash_prompt_color_term} -eq 1 ] && bash_prompt_ps1+="\[$(bd_ansi reset)\]"

    local bash_prompt_glyphs=''

    # glyph: git is detected; do what?
    if [ -d .git ]; then
        #bash_prompt_glyphs+=''
        #bash_prompt_glyphs+='‡'
        #bash_prompt_glyphs+='g'
        #bash_prompt_glyphs+='❡'
        #bash_prompt_glyphs+='∴'
        #bash_prompt_glyphs+='♅'
        #bash_prompt_glyphs+='♪'
        bash_prompt_glyphs+='♬'
    fi

    # glyph: etc/bash.d is detected; add a symbol
    if [ ${BD_ID} ] && [ -d etc/bash.d ]; then
        bash_prompt_glyphs+='♭'

        #bash_prompt_glyphs+="$(bd_ansi bg_green5)"
        #bash_prompt_glyphs+='‡' # ok
        #bash_prompt_glyphs+='↻'
        #bash_prompt_glyphs+='⍎'
        #bash_prompt_glyphs+='⚙'
        #bash_prompt_glyphs+='⌱'
        #'ƃƌ'
        #'⌇'
        #'⇱'
        #'⌑'
        #'⌓'
    fi

    [ ${#bash_prompt_glyphs} -gt 0 ] && bash_prompt_ps1+="${bash_prompt_glyphs}"

    # append colored/utf-8 symbols for # and $
    if [ ${bash_prompt_color_term} -eq 1 ]; then
        if [ "${USER}" == 'root' ]; then
            bash_prompt_color="$(bd_ansi fg_yellow1)"
        else
            [ "${USER}" == 'duce' ] && bash_prompt_color="$(bd_ansi fg_green1)" || bash_prompt_color="$(bd_ansi fg_gray1)"
        fi
        bash_prompt_ps1+="\[${bash_prompt_color}\]"
    fi

    #[ "${USER}" == 'root' ] && bash_prompt_ps1+="﹟" || bash_prompt_ps1+="﹩"
    [ "${USER}" == 'root' ] && bash_prompt_ps1+='♯' || bash_prompt_ps1+='$'
    #"﹟"

    # single symbols that are multibyte tend to have some additional visible space & an extra space is subjective
    bash_prompt_ps1+=' '

    [ ${bash_prompt_color_term} -eq 1 ] && bash_prompt_ps1+="\[$(bd_ansi reset)\]"

    # set the promp
    PS1="${bash_prompt_ps1}"

    unset -v bash_prompt_color_term bash_prompt_window_title bash_prompt_ps1 bash_prompt_color
}

PROMPT_COMMAND='bash_prompt'
