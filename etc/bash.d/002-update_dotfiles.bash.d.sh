#!/usr/bin/env bash
# Pull the latest dotfiles from Github

function update_dotfiles() {
    local dotowners=(duce dtate ducet8)
    dotdir="${HOME}/dotfiles"
    if [[ (" ${dotowners[*]} " =~ " ${USER} ") && (-d ${dotdir}) ]]; then
        export PATH=~/local/bin:$PATH
        if [ -d ${dotdir}/.git ]; then
            git -C "${dotdir}" fetch &> /dev/null

            local git_ahead_behind=$(git -C "${dotdir}" rev-list --left-right --count master...origin/master | tr -s '\t' '|';)
            local git_ahead=$(echo "${git_ahead_behind}" | awk -F\| '{print $1}')
            local git_behind=$(echo "${git_ahead_behind}" | awk -F\| '{print $2}')
            if [[ ${git_ahead} -lt ${git_behind} ]]; then
                elog notice "git_head_upstream = $(git -C "${dotdir}" rev-parse HEAD@{u} 2>/dev/null)"
                elog notice "git_head_working = $(git -C "${dotdir}" rev-parse HEAD 2>/dev/null)"

                git -C "${dotdir}" pull
            fi
        else
            elog alert "${dotdir} was not a git repository"

            local cwd=$(pwd 2>/dev/null)
            mkdir -p "${dotdir}"
            cd "${dotdir}" &>/dev/null
            git init
            git remote add origin git@github.com:ducet8/dotfiles
            git fetch
            git checkout -t origin/master -f
            git reset --hard
            git checkout -- .
            cd "${cwd}" &>/dev/null
        fi
    fi
}

update_dotfiles