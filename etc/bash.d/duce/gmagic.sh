# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if ! type -P git &>/dev/null; then
    return 0
fi

# git config --global alias.magic '!f() { git add -A && git commit -m "$@" && git push; }; f'
gmagic() {
    git add --all
    git commit -am "$*"
    git push
}
