# 2022.12.14 - ducet8@outlook.com

# Read exported functions and pipe them through bat, if available
function fat() {
    if type -P bat &>/dev/null; then
        typeset -f ${1} | bat -l sh --paging=never --theme="gruvbox-dark"
    else
        typeset -f ${1}
    fi
}

