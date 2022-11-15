# 2022.11.09 - ducet8@outlook.com

if ! type -P tree &>/dev/null; then
    return 0
fi

function tre() {
	tree -aC -I '.git' --dirsfirst "$@" | less -FRNX
}

# export -f tre