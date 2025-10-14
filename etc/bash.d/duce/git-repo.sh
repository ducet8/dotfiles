# vim: ft=sh
# Open git repository in browser
# Forked from: Jess Frizelle (https://github.com/zeke/ghwd)
# 2023.08.28 - ducet8@outlook.com

if ! type -P git &>/dev/null; then
    return 0
fi

repo() {
    local version='2.0.0'
    
    print_help() {
        local program="repo"
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf 'Open git repository in browser\n\n'
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\t%s [file_or_directory]\n' "${program}"
            bd_ansi fg_yellow3
            printf 'ARGUMENTS:\n'
            bd_ansi fg_blue1
            printf '\tfile_or_directory'
            bd_ansi reset
            printf '\tOptional path to open specific file/directory\n'
            bd_ansi fg_yellow3
            printf 'OPTIONS:\n'
            bd_ansi fg_blue1
            printf '\t-h|--help'
            bd_ansi reset
            printf '\t\tShow this help\n'
            bd_ansi fg_yellow3
            printf 'EXAMPLES:\n'
            bd_ansi reset
            printf '\t%s\t\t\tOpen repository root\n' "${program}"
            printf '\t%s README.md\t\tOpen specific file\n' "${program}"
            printf '\t%s src/\t\t\tOpen specific directory\n' "${program}"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "Open git repository in browser\n\n"
            printf "USAGE:\n"
            printf "\t%s [file_or_directory]\n" "${program}"
            printf "ARGUMENTS:\n"
            printf "\tfile_or_directory\tOptional path to open specific file/directory\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "EXAMPLES:\n"
            printf "\t%s\t\t\tOpen repository root\n" "${program}"
            printf "\t%s README.md\t\tOpen specific file\n" "${program}"
            printf "\t%s src/\t\t\tOpen specific directory\n" "${program}"
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

    open_url() {
        local url="$1"
        
        if type bd_ansi &>/dev/null; then
            printf "Opening: "
            bd_ansi fg_cyan1
            printf "%s\n" "${url}"
            bd_ansi reset
        else
            printf "Opening: %s\n" "${url}"
        fi
        
        # Cross-platform browser opening
        if [[ "${BD_OS}" == "darwin" ]] || command -v open &>/dev/null; then
            open "${url}" &>/dev/null
        elif [[ "${BD_OS}" == "linux" ]] || command -v xdg-open &>/dev/null; then
            xdg-open "${url}" &>/dev/null
        elif command -v start &>/dev/null; then
            start "${url}" &>/dev/null
        else
            abort_with_message "No browser opener found (tried: open, xdg-open, start)"
        fi
    }

    # Handle help flags
    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
    esac

    # Check if we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        abort_with_message "Not in a git repository"
    fi

    # Get remote URL
    local remote_url
    remote_url="$(git config --get remote.origin.url 2>/dev/null)"
    if [[ -z "${remote_url}" ]]; then
        abort_with_message "No remote 'origin' found"
    fi

    # Convert to HTTPS URL
    local base_url=""
    if [[ "${remote_url}" =~ ^git@([^:]+):(.+)$ ]]; then
        local host="${BASH_REMATCH[1]}"
        local repo_path="${BASH_REMATCH[2]}"
        # Strip .git suffix if present
        repo_path="${repo_path%.git}"
        base_url="https://${host}/${repo_path}"
    elif [[ "${remote_url}" =~ ^https://([^/]+)/(.+)$ ]]; then
        local host="${BASH_REMATCH[1]}"
        local repo_path="${BASH_REMATCH[2]}"
        # Strip .git suffix if present
        repo_path="${repo_path%.git}"
        base_url="https://${host}/${repo_path}"
    else
        abort_with_message "Unsupported remote URL format: ${remote_url}"
    fi

    # Get current branch
    local current_branch
    current_branch="$(git branch --show-current 2>/dev/null)"
    if [[ -z "${current_branch}" ]]; then
        current_branch="$(git rev-parse --short HEAD 2>/dev/null)"
    fi

    # Find current directory relative to git root
    local git_root
    git_root="$(git rev-parse --show-toplevel)"
    local current_path
    current_path="$(realpath "$(pwd)")"
    local relative_path="${current_path#${git_root}}"
    
    # Clean up the relative path
    if [[ "${relative_path}" == "${current_path}" ]]; then
        # We're outside the git repo, use git rev-parse to get the proper relative path
        relative_path="$(git rev-parse --show-prefix 2>/dev/null || echo "")"
        relative_path="/${relative_path%/}" # Remove trailing slash, add leading slash
    elif [[ -n "${relative_path}" && "${relative_path}" != /* ]]; then
        relative_path="/${relative_path}"
    fi

    # If filename/directory argument is present, append it
    if [[ -n "${1}" ]]; then
        relative_path="${relative_path}/${1}"
    fi

    # Determine tree/src path based on host
    local tree_path="tree"
    if [[ "${base_url}" == *bitbucket* ]]; then
        tree_path="src"
    fi

    # Construct final URL
    local final_url="${base_url}/${tree_path}/${current_branch}${relative_path}"

    open_url "${final_url}"
}
