# 2022.11.09 - ducet8@outlook.com

# Pull the latest dotfiles from Github

if ! type -P git &>/dev/null; then
    return 0
fi

function update_dotfiles() {
    local dotowners=(duce dtate ducet8)
    local dotdir="${HOME}/dotfiles"
    if [[ (" ${dotowners[*]} " =~ " ${USER} ") && (-d ${dotdir}) ]]; then
        export PATH=~/local/bin:$PATH
        if [ -d ${dotdir}/.git ]; then
            git -C "${dotdir}" fetch &> /dev/null
            if ! git -C ${dotdir} diff --quiet &> /dev/null; then
                local git_ahead_behind=$(git -C "${dotdir}" rev-list --left-right --count master...origin/master | tr -s '\t' '|';)
                local git_ahead=$(echo "${git_ahead_behind}" | awk -F\| '{print $1}')
                local git_behind=$(echo "${git_ahead_behind}" | awk -F\| '{print $2}')
                if [[ ${git_ahead} -lt ${git_behind} ]]; then
                    bd_ansi dim; bd_ansi gray
                    echo "NOTICE: git_head_upstream = $(git -C "${dotdir}" rev-parse HEAD@{u} 2>/dev/null)"
                    echo "NOTICE: git_head_working = $(git -C "${dotdir}" rev-parse HEAD 2>/dev/null)"

                    git -C "${dotdir}" pull --ff-only
                    bd_ansi reset
                fi
            fi
        else
            bd_ansi dim; bd_ansi fg_red 
            echo "ALERT: ${dotdir} was not a git repository"
            bd_ansi reset

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

stamp=$(date +%Y%m%d)
if [ ! -f ${HOME}/.profile_git_check_${stamp} ]; then
    update_dotfiles
    
    rm "${HOME}/.profile_git_check_"*
    touch "${HOME}/.profile_git_check_${stamp}"
fi
unset stamp