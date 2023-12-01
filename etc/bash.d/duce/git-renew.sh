# vim: ft=sh
# 2023.12.01 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

git-renew() {
    local git_renew_version="1.0.0-a"

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "git-renew"
            bd_ansi reset
            printf "\t${git_renew_version}\n"
            printf "Change to the repo's parent directory, remove the repo, re-clone the repo, cd back to the working directory, and switch to the current branch.\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\tgit-renew [OPTIONS]\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "     Displays this help\n"
            bd_ansi reset
        else
            printf "git-renew\t${git_renew_version}\n"
            printf "Change to the repo's parent directory, remove the repo, re-clone the repo, cd back to the working directory, and switch to the current branch.\n\n"
            printf "USAGE:\n"
            printf "\tgit-renew [OPTIONS]\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help     Show this help message and exit\n"
        fi
    }

    if [ $# -ne 0 ]; then
        print_help
        if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
            return 0
        fi
        return 1
    fi

    if ! $(git rev-parse --is-inside-work-tree 2>/dev/null); then
        printf "Not in a git repository.\n\n"
        print_help
        return 1
    fi

    local current_repo=$(git config --get remote.origin.url)
    local current_branch=$(git symbolic-ref --short HEAD)
    local repo_root=$(git rev-parse --show-toplevel)
    local current_dir=$(pwd)

    if type bd_ansi &>/dev/null; then
        cd "${repo_root}/.." &>/dev/null || exit
        bd_ansi fg_blue1
        printf "Removing ${repo_root}...\n"
        rm -Rf "${repo_root}"
        printf "Cloning ${current_repo}...\n"
        bd_ansi reset
        git clone "${current_repo}" "${repo_root}"
        cd "${current_dir}" &>/dev/null || exit
        bd_ansi fg_blue1
        printf "Checking out ${current_branch}...\n"
        bd_ansi reset
        git checkout "${current_branch}"
        git pull
        bd_ansi fg_green1
        printf "Repository renewed successfully.\n"
        bd_ansi reset
    else
        cd "${repo_root}/.." &>/dev/null || exit
        echo "Removing ${repo_root}..."
        rm -Rf "${repo_root}"
        echo
        echo "Cloning ${current_repo}..."
        git clone ${current_repo} "${repo_root}"
        cd "${current_dir}" &>/dev/null || exit
        echo
        echo "Checking out ${current_branch}..."
        git checkout "${current_branch}"
        git pull
        echo
        echo "Repository renewed successfully."
    fi
}

