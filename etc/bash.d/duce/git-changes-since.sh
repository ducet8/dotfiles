# vim: ft=sh
# 2024.05.15 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P git &>/dev/null; then
    return 1
fi

git-changes-since() {
    local git_changes_since_version="1.0.0-a"

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "git-changes-since"
            bd_ansi reset
            printf "\t${git_changes_since_version}\n"
            printf "Display the unique files that have changed since the supplied date\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\tgit-changes-since [OPTIONS] [ARGUMENTS]\n"
            bd_ansi fg_yellow3
            printf "ARGUMENTS:\n"
            bd_ansi fg_blue1
            printf "\t[DATE]"
            bd_ansi reset
            printf "        Date to search from (YYYY-MM-DD|MM/DD/YYYY|X days ago)"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "     Displays this help\n"
            bd_ansi reset
        else
            printf "git-changes-since\t${git_changes_since_version}\n"
            printf "Display the unique files that have changed since the supplied date\n\n"
            printf "ARGUMENTS:\n"
            printf "\t[DATE]        Date to search from (YYYY-MM-DD|MM/DD/YYYY|X days ago)"
            printf "USAGE:\n"
            printf "\tgit-changes-since [OPTIONS]\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help     Show this help message and exit\n"
        fi
    }

    if [ $# -ne 1 ]; then
        print_help
        return 1
    fi

    if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
        print_help
        return 0
    fi

    if ! $(git rev-parse --is-inside-work-tree 2>/dev/null); then
        printf "Not in a git repository.\n\n"
        print_help
        return 1
    fi

    if type bd_ansi &>/dev/null; then
        bd_ansi fg_green1
        git log --since="${1}" --name-only --pretty=format: | sort | uniq
        bd_ansi reset
        echo
    else
        git log --since="${1}" --name-only --pretty=format: | sort | uniq
        echo
    fi
}

