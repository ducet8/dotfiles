#!/usr/bin/env bash

if ! type -P git &>/dev/null; then
    return 0
fi

# git config --global alias.magic '!f() { git add -A && git commit -m "$@" && git push; }; f'
function gmagic() {
    git add --all
    git commit -am "$*"
    git push
}

export -f gmagic