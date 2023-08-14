# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if ! type -P bat &>/dev/null && type -P git &>/dev/null; then
    return 0
fi

batdiff() {
    git diff --name-only --diff-filter=d | xargs bat --diff
}
