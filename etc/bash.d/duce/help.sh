# vim: ft=sh
# 2023.11.01 - ducet8@outlook.com

help() {
    if type -P bat &>/dev/null && type -P git &>/dev/null; then
        "$@" --help 2>&1 | bat --plain --language=help
    else
        "$@" --help
    fi
}
