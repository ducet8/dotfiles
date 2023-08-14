# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if ! type -P tree &>/dev/null; then
    return 0
fi

tre() {
	tree -aC -I '.git' --dirsfirst "$@" | less -FRNX
}
