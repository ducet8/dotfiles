# vim: ft=sh
# Forked from: Jess Frizelle
# 2023.08.14 - ducet8@outlook.com

if ! type -P dig &>/dev/null; then
    return 0
fi

digga() {
    dig +nocmd "${1}" any +multiline +noall +answer
}
