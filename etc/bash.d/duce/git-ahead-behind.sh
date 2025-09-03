# vim: ft=sh
# Show ahead/behind status for current git branch
# 2023.08.14 - ducet8@outlook.com

if ! type -P git &>/dev/null; then
    return 0
fi

git-ahead-behind() {
    local version="1.1.0"
    
    print_help() {
        local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf "Show how many commits the current branch is ahead/behind its tracking branch\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s [options]\n" "${program}"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
            bd_ansi fg_blue1
            printf "\t-r|--raw"
            bd_ansi reset
            printf "\t\tOutput raw format (ahead|behind)\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s\t\t\tShow formatted ahead/behind status\n" "${program}"
            printf "\t%s -r\t\t\tShow raw format for scripting\n" "${program}"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "Show how many commits the current branch is ahead/behind its tracking branch\n\n"
            printf "USAGE:\n"
            printf "\t%s [options]\n" "${program}"
            printf "OPTIONS:\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "\t-r|--raw\t\tOutput raw format (ahead|behind)\n"
            printf "EXAMPLES:\n"
            printf "\t%s\t\t\tShow formatted ahead/behind status\n" "${program}"
            printf "\t%s -r\t\t\tShow raw format for scripting\n" "${program}"
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
    
    local raw_output=false
    
    # Parse arguments
    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
        -r|--raw)
            raw_output=true
            ;;
        "")
            # No arguments is fine
            ;;
        *)
            abort_with_message "Unknown option: ${1}"
            ;;
    esac
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        abort_with_message "Not in a git repository"
    fi
    
    # Get current branch
    local curr_branch
    curr_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
        abort_with_message "Could not determine current branch"
    }
    
    # Check if branch has a remote tracking branch
    local curr_remote
    curr_remote=$(git config "branch.${curr_branch}.remote" 2>/dev/null) || {
        abort_with_message "Branch '${curr_branch}' has no remote tracking branch"
    }
    
    local curr_merge_branch
    curr_merge_branch=$(git config "branch.${curr_branch}.merge" 2>/dev/null | cut -d / -f 3) || {
        abort_with_message "Branch '${curr_branch}' has no merge configuration"
    }
    
    # Check if remote branch exists
    if ! git show-ref --verify --quiet "refs/remotes/${curr_remote}/${curr_merge_branch}"; then
        abort_with_message "Remote branch '${curr_remote}/${curr_merge_branch}' does not exist"
    fi
    
    # Get ahead/behind counts
    local counts
    counts=$(git rev-list --left-right --count "${curr_branch}...${curr_remote}/${curr_merge_branch}" 2>/dev/null) || {
        abort_with_message "Could not determine ahead/behind status"
    }
    
    local ahead behind
    ahead=$(echo "${counts}" | cut -f1)
    behind=$(echo "${counts}" | cut -f2)
    
    if [[ "${raw_output}" == true ]]; then
        printf "%s|%s\n" "${ahead}" "${behind}"
    else
        if type bd_ansi &>/dev/null; then
            if [[ "${ahead}" -gt 0 && "${behind}" -gt 0 ]]; then
                bd_ansi fg_yellow3
                printf "%s ahead" "${ahead}"
                bd_ansi reset
                printf " | "
                bd_ansi fg_cyan1
                printf "%s behind\n" "${behind}"
                bd_ansi reset
            elif [[ "${ahead}" -gt 0 ]]; then
                bd_ansi fg_yellow3
                printf "%s ahead\n" "${ahead}"
                bd_ansi reset
            elif [[ "${behind}" -gt 0 ]]; then
                bd_ansi fg_cyan1
                printf "%s behind\n" "${behind}"
                bd_ansi reset
            else
                bd_ansi fg_green1
                printf "up to date\n"
                bd_ansi reset
            fi
        else
            if [[ "${ahead}" -gt 0 && "${behind}" -gt 0 ]]; then
                printf "%s ahead | %s behind\n" "${ahead}" "${behind}"
            elif [[ "${ahead}" -gt 0 ]]; then
                printf "%s ahead\n" "${ahead}"
            elif [[ "${behind}" -gt 0 ]]; then
                printf "%s behind\n" "${behind}"
            else
                printf "up to date\n"
            fi
        fi
    fi
}
