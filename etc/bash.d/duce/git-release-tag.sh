# vim: ft=sh
# 2025.12.23 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P gh &>/dev/null; then
    return 0
fi

git-release-tag() {
    local version="1.0.0"

    print_help() {
        local program="git-release-tag"

        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf "Get the latest release tag from a GitHub repository\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s [OPTIONS] <repo-name>\n" "${program}"
            bd_ansi fg_yellow3
            printf "ARGUMENTS:\n"
            bd_ansi fg_blue1
            printf "\t<repo-name>"
            bd_ansi reset
            printf "\t\tRepository name (will use csbproserve/<repo-name>)\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s my-repo\n" "${program}"
            printf "\t%s another-project\n" "${program}"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "Get the latest release tag from a GitHub repository\n\n"
            printf "USAGE:\n"
            printf "\t%s [OPTIONS] <repo-name>\n" "${program}"
            printf "ARGUMENTS:\n"
            printf "\t<repo-name>\t\tRepository name (will use csbproserve/<repo-name>)\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "EXAMPLES:\n"
            printf "\t%s my-repo\n" "${program}"
            printf "\t%s another-project\n" "${program}"
        fi
    }

    abort_with_message() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_red1
            printf "\n✗ %s\n\n" "$*"
            bd_ansi reset
        else
            printf "\n✗ %s\n\n" "$*"
        fi
        return 1
    }

    # Handle help flags
    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
    esac

    # Validate exactly one argument
    if [[ $# -eq 0 ]]; then
        abort_with_message "Repository name required"
        print_help
        return 1
    fi

    if [[ $# -gt 1 ]]; then
        abort_with_message "Too many arguments. Expected exactly one repository name."
        print_help
        return 1
    fi

    local repo_name="${1}"

    # Run the gh command
    gh release view --repo "csbproserve/${repo_name}" --json tagName --jq '.tagName'
}
