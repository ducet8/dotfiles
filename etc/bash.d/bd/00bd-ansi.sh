# Copyright (c) 2022 Joseph Tingiris
# https://github.com/bash-d/bd/blob/main/LICENSE.md

# DO NOT USE bd_debug() inside this function!

#
# metadata
#

# bash.d: exports BD_DEBUG BD_ID BD_HOME BD_USER BD_VERSION
# vim: ft=sh:ts=4:sw=4

#
# functions
#

function bd_ansi() {
    local bd_ansi_code="${1}"

    [ ${#bd_ansi_code} -eq 0 ] && return 0

    [[ "${TERM}" != *'color' ]] && return 0

    local bd_ansi_reset='\e[m'

    # all color 256 terms should support these ...

    case ${bd_ansi_code} in
        blink) echo -ne '\e[5m' ;;
        bold) echo -ne '\e[1m' ;;
        dim) echo -ne '\e[2m' ;;
        hidden) echo -ne '\e[8m' ;;
        reset) echo -ne "${bd_ansi_reset}" ;;
        reverse) echo -ne '\e[7m' ;;
        underline) echo -ne '\e[4m' ;;

        bg_default) echo -ne '\e[49m' ;;
        fg_default) echo -ne '\e[39m' ;;

        bg_black1|bg_black) echo -ne '\e[48;5;0m' ;;
        fg_black1|fg_black|black) echo -ne '\e[38;5;0m' ;;

        bg_white1|bg_white) echo -ne '\e[48;5;7m' ;;
        fg_white1|fg_white|white) echo -ne '\e[38;5;7m' ;;

        bg_red1|bg_red) echo -ne '\e[48;5;9m' ;;
        bg_red2) echo -ne '\e[48;5;1m' ;;
        bg_red3) echo -ne '\e[48;5;124m' ;;
        bg_red4) echo -ne '\e[48;5;88m' ;;
        bg_red5) echo -ne '\e[48;5;52m' ;;

        fg_red1|fg_red|red) echo -ne '\e[38;5;9m' ;;
        fg_red2) echo -ne '\e[38;5;1m' ;;
        fg_red3) echo -ne '\e[38;5;124m' ;;
        fg_red4) echo -ne '\e[38;5;88m' ;;
        fg_red5) echo -ne '\e[38;5;52m' ;;

        bg_blue1|bg_blue) echo -ne '\e[48;5;4m' ;;
        bg_blue2) echo -ne '\e[48;5;12m' ;;
        bg_blue3) echo -ne '\e[48;5;19m' ;;
        bg_blue4) echo -ne '\e[48;5;18m' ;;
        bg_blue5) echo -ne '\e[48;5;17m' ;;

        fg_blue1|fg_blue|blue) echo -ne '\e[38;5;4m' ;;
        fg_blue2) echo -ne '\e[38;5;12m' ;;
        fg_blue3) echo -ne '\e[38;5;19m' ;;
        fg_blue4) echo -ne '\e[38;5;18m' ;;
        fg_blue5) echo -ne '\e[38;5;17m' ;;

        bg_green1|bg_green) echo -ne '\e[48;5;10m' ;;
        bg_green2) echo -ne '\e[48;5;2m' ;;
        bg_green3) echo -ne '\e[48;5;34m' ;;
        bg_green4) echo -ne '\e[48;5;28m' ;;
        bg_green5) echo -ne '\e[48;5;22m' ;;

        fg_green1|fg_green|green) echo -ne '\e[38;5;10m' ;;
        fg_green2) echo -ne '\e[38;5;2m' ;;
        fg_green3) echo -ne '\e[38;5;34m' ;;
        fg_green4) echo -ne '\e[38;5;28m' ;;
        fg_green5) echo -ne '\e[38;5;22m' ;;

        bg_gray1|bg_gray|bg_grey1|bg_grey) echo -ne '\e[48;5;254m' ;;
        bg_gray2|bg_grey2) echo -ne '\e[48;5;250m' ;;
        bg_gray3|bg_grey3) echo -ne '\e[48;5;246m' ;;
        bg_gray4|bg_grey4) echo -ne '\e[48;5;242m' ;;
        bg_gray5|bg_grey5) echo -ne '\e[48;5;238m' ;;

        fg_gray1|fg_gray|gray|fg_grey1|gr_grey|grey) echo -ne '\e[38;5;254m' ;;
        fg_gray2|fg_grey2) echo -ne '\e[38;5;250m' ;;
        fg_gray3|fg_grey3) echo -ne '\e[38;5;246m' ;;
        fg_gray4|fg_grey4) echo -ne '\e[38;5;242m' ;;
        fg_gray5|fg_grey5) echo -ne '\e[38;5;238m' ;;

        bg_yellow1|bg_yellow) echo -ne '\e[48;5;11m' ;;
        bg_yellow2) echo -ne '\e[48;5;3m' ;;
        bg_yellow3) echo -ne '\e[48;5;220m' ;;
        bg_yellow4) echo -ne '\e[48;5;220m' ;;
        bg_yellow5) echo -ne '\e[48;5;208m' ;;

        fg_yellow1|fg_yellow|yellow) echo -ne '\e[38;5;11m' ;;
        fg_yellow2) echo -ne '\e[38;5;3m' ;;
        fg_yellow3) echo -ne '\e[38;5;220m' ;;
        fg_yellow4) echo -ne '\e[38;5;214m' ;;
        fg_yellow5) echo -ne '\e[38;5;208m' ;;

        bg_magenta1|bg_magenta) echo -ne '\e[48;5;13m' ;;
        bg_magenta2) echo -ne '\e[48;5;5m' ;;
        bg_magenta3) echo -ne '\e[48;5;93m' ;;
        bg_magenta4) echo -ne '\e[48;5;57m' ;;
        bg_magenta5) echo -ne '\e[48;5;55m' ;;

        fg_magenta1|fg_magent|magenta) echo -ne '\e[38;5;13m' ;;
        fg_magenta2) echo -ne '\e[38;5;5m' ;;
        fg_magenta3) echo -ne '\e[38;5;93m' ;;
        fg_magenta4) echo -ne '\e[38;5;57m' ;;
        fg_magenta5) echo -ne '\e[38;5;55m' ;;

        bg*) bd_ansi_code=${bd_ansi_code/bg/}; bd_ansi_code=${bd_ansi_code//_/}; [[ "${bd_ansi_code}" =~ ^[0-9]+$ ]] && echo -ne "\e[48;5;${bd_ansi_code}m" ;;

        fg*) bd_ansi_code=${bd_ansi_code/fg/}; bd_ansi_code=${bd_ansi_code//_/}; [[ "${bd_ansi_code}" =~ ^[0-9]+$ ]] && echo -ne "\e[38;5;${bd_ansi_code}m" ;;

        *)
            echo "${FUNCNAME} no bd_ansi_code for '${bd_ansi_code}'" 1>&2
            ;;
    esac

    if [ "${2}" != "" ]; then
        echo -n "${2}"
        echo -e "${bd_ansi_reset}"
    fi

    return 0
}
