# vim: ft=sh
# 2024.06.27 - ducet8@outlook.com

if ! type -P git &>/dev/null; then
    return 0
fi

git-info() {
    local git_info_version='1.0.0-a'

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf 'git-info'
            bd_ansi reset
            printf "\t${git_info_version}\n"
            printf 'Display information about current git repository\n\n'
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\tgit-info [OPTIONS]\n'
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-r|--remote"
            bd_ansi reset
            printf "     Display information about the remote\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "       Displays this help\n"
            bd_ansi reset
        else
            printf "git-info\t${git_info_version}\n"
            printf "Display information about current git repository\n\n"
            printf "USAGE:\n"
            printf "\tgit-info [OPTIONS]\n"
            printf "OPTIONS:\n"
            printf "\t-r|--remote     Display information about the remote\n"
            printf "\t-h|--help       Displays this help\n"
        fi
    }

    if [ $# -gt 1 ]; then
        print_help
        return 1
    fi

    # Process arguments
    while [ $# -gt 0 ]; do
        case "${1}" in
            -r|--remote)
                local remote=0
                shift
                ;;
            -h|--help)
                print_help
                return 0
                ;;
            *)
                echo 'Invalid option' && echo
                print_help
                return 1
                ;;
        esac
    done

    local local_commit_hash="$(git log -1 --format="%h" 2>>/dev/null)"
    local local_release_tag="$(git describe --tags --abbrev=0 2>>/dev/null)"

    if [ -z ${remote} ]; then
        if type bd_ansi &>/dev/null; then
            bd_ansi reset
            if [[ ! -z "${local_commit_hash}" ]]; then
                printf 'Latest local commit hash:'
                bd_ansi fg_cyan3
                printf "\t${local_commit_hash}\n"
                bd_ansi reset
            fi
            if [[ ! -z "${local_release_tag}" ]]; then
                printf 'Latest local release tag:'
                bd_ansi fg_cyan3
                printf "\t${local_release_tag}\n"
                bd_ansi reset
            fi
        else
            if [[ ! -z "${local_commit_hash}" ]]; then
                echo "Latest local commit hash:  ${local_commit_hash}"
            fi
            if [[ ! -z "${local_release_tag}" ]]; then
                echo "Latest local release tag:  ${local_release_tag}"
            fi
        fi
    else
        local remote_commit_hash="$(git log -1 --format="%h" --remotes=origin 2>>/dev/null)"
        local remote_release_tag="$(git ls-remote --tags --sort=-v:refname origin 2>>/dev/null | grep -v "\^" | grep "main-v" | awk '{print $2}' | awk -F/ '{print $3}' | head -1)"

        if type bd_ansi &>/dev/null; then
            bd_ansi reset
            if [[ ! -z "${local_commit_hash}" ]]; then
                printf 'Latest local commit hash:' 
                bd_ansi fg_cyan3
                printf "\t${local_commit_hash}\n"
                bd_ansi reset
            fi
            if [[ ! -z "${local_release_tag}" ]]; then
                printf 'Latest local release tag:'
                bd_ansi fg_cyan3
                printf "\t${local_release_tag}\n"
                bd_ansi reset
            fi
            if [[ ! -z "${remote_commit_hash}" ]]; then
                printf 'Latest remote commit hash:'
                bd_ansi fg_cyan3
                printf "\t${remote_commit_hash}\n"
                bd_ansi reset
            fi
            if [[ ! -z "${remote_release_tag}" ]]; then
                printf 'Latest remote release tag:'
                bd_ansi fg_cyan3
                printf "\t${remote_release_tag}\n"
                bd_ansi reset
            fi
        else
            if [ -n ${local_commit_hash} ]; then
                echo "Latest local commit hash:   ${local_commit_hash}"
            fi
            if [ -n ${local_release_tag} ]; then
                echo "Latest local release tag:   ${local_release_tag}"
            fi
            if [ -n ${remote_commit_hash} ]; then
                echo "Latest remote commit hash:  ${remote_commit_hash}"
            fi
            if [ -n ${remote_release_tag} ]; then
                echo "Latest remote release tag:  ${remote_release_tag}"
            fi
        fi
    fi
}

