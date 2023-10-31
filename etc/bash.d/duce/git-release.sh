# vim: ft=sh
# 2023.10.31 - ducet8@outlook.com

git-release() {
    local git_release_version="1.0.0-a"
    local branch

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "git-release"
            bd_ansi reset
            printf "\t${git_release_version}\n"
            printf "Determine the latest release in github for the current repo\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\tgit-release [OPTIONS]\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-b|--branch <branch_name>"
            bd_ansi reset
            printf "   Specify a branch other then the current branch (default)\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "                   Displays this help\n"
            bd_ansi reset
        else
            printf "git-release\t${git_release_version}\n"
            printf "Determine the latest release in github for the current repo\n\n"
            printf "USAGE:\n"
            printf "\tgit-release [OPTIONS]\n"
            printf "OPTIONS:\n"
            printf "\t-b|--branch <branch_name>   Specify a branch other then the current branch (default)\n"
            printf "\t-h|--help                   Displays this help\n"
        fi
    }

    if [[ ${1} == -* ]]; then
        case "${1}" in
            -b|--branch)
                shift
                if [ -n "${1}" ]; then
                    branch="${1}"
                    shift
                else
                    echo "A branch must be specified with the --branch option" && echo
                    return 1
                fi
                ;;

            -h|--help)
                print_help
                return 0
                ;;

            *)
                echo "Invalid option" && echo
                print_help
                return 1
                ;;
        esac
    fi

    if [[ -z "${branch}" ]]; then
        branch="$(git branch | grep '*' | awk '{print $2}')"
    fi

    git ls-remote --tags --refs -q | grep ${branch} | awk -F/ '{print $3}' | tail -n 1
}
