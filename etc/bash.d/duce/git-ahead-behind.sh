# 2022.11.09 - ducet8@outlook.com

if ! type -P git &>/dev/null; then
    return 0
fi

function git_ahead_behind() {
    curr_branch=$(git rev-parse --abbrev-ref HEAD)
    curr_remote=$(git config branch.${curr_branch}.remote)
    curr_merge_branch=$(git config branch.${curr_branch}.merge | cut -d / -f 3)
    git rev-list --left-right --count ${curr_branch}...${curr_remote}/${curr_merge_branch} | tr -s '\t' '|'
}

# export -f git_ahead_behind