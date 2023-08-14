# vim: ft=sh
# 2023.01.18 - ducet8@outlook.com

help() {
    "$@" --help 2>&1 | bat --plain --language=help
}
