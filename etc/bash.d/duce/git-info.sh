# vim: ft=sh
# 2025.09.03 - ducet8@outlook.com

if ! type -P git &>/dev/null; then
    return 0
fi

git-info() {
    local version='2.0.0'

    print_help() {
        local program="git-info"
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf 'Display comprehensive information about current git repository\n\n'
            bd_ansi fg_yellow3
            printf 'USAGE:\n'
            bd_ansi reset
            printf '\t%s [OPTIONS]\n' "${program}"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-l|--local"
            bd_ansi reset
            printf "\t\tDisplay local information only\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "Display comprehensive information about current git repository\n\n"
            printf "USAGE:\n"
            printf "\t%s [OPTIONS]\n" "${program}"
            printf "OPTIONS:\n"
            printf "\t-l|--local\t\tDisplay local information only\n"
            printf "\t-h|--help\t\tShow this help\n"
        fi
    }

    # Check if we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        printf "Error: Not in a git repository\n"
        return 1
    fi

    # Initialize flags - default to showing all information
    local show_local_only=false

    # Process arguments
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -l|--local)
                show_local_only=true
                shift
                ;;
            -h|--help)
                print_help
                return 0
                ;;
            *)
                printf "Error: Invalid option '%s'\n\n" "${1}"
                print_help
                return 1
                ;;
        esac
    done

    display_info() {
        local label="$1"
        local value="$2"
        local color="${3:-fg_cyan1}"
        
        if [[ -n "${value}" ]]; then
            if type bd_ansi &>/dev/null; then
                printf '%-20s' "${label}:"
                bd_ansi "${color}"
                printf '%s\n' "${value}"
                bd_ansi reset
            else
                printf '%-20s%s\n' "${label}:" "${value}"
            fi
        fi
    }

    # Gather git information
    local current_branch="$(git branch --show-current 2>/dev/null)"
    local commit_hash="$(git log -1 --format='%h' 2>/dev/null)"
    local commit_date="$(git log -1 --format='%ci' 2>/dev/null | cut -d' ' -f1)"
    local commit_author="$(git log -1 --format='%an' 2>/dev/null)"
    local commit_message="$(git log -1 --format='%s' 2>/dev/null)"
    local repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    local latest_tag="$(git describe --tags --abbrev=0 2>/dev/null)"
    local stash_count="$(git stash list 2>/dev/null | wc -l | tr -d ' ')"
    local remote_url="$(git remote get-url origin 2>/dev/null)"
    
    # Convert SSH URL to HTTPS for clickable link
    local https_url=""
    if [[ -n "${remote_url}" ]]; then
        if [[ "${remote_url}" =~ ^git@github\.com:(.+)(\.git)?$ ]]; then
            https_url="https://github.com/${BASH_REMATCH[1]}"
        elif [[ "${remote_url}" =~ ^https://github\.com/(.+)(\.git)?$ ]]; then
            https_url="https://github.com/${BASH_REMATCH[1]}"
        elif [[ "${remote_url}" =~ ^https://github\.com/(.+)$ ]]; then
            https_url="${remote_url}"
        fi
    fi

    # Display basic information
    display_info "Repository root" "${repo_root}" "fg_blue1"
    display_info "Current branch" "${current_branch}" "fg_green1"
    
    # Combined commit info
    if [[ -n "${commit_hash}" && -n "${commit_date}" && -n "${commit_author}" ]]; then
        local commit_info="${commit_hash} (${commit_date}) ${commit_author}"
        if [[ -n "${commit_message}" ]]; then
            commit_info="${commit_info}: ${commit_message}"
        fi
        display_info "Latest commit" "${commit_info}" "fg_cyan1"
    fi
    
    display_info "Latest tag" "${latest_tag}" "fg_yellow3"
    
    if [[ "${stash_count}" -gt 0 ]]; then
        display_info "Stashes" "${stash_count}" "fg_yellow3"
    fi

    # Display remote and status information unless --local is specified
    if [[ "${show_local_only}" == false ]]; then
        # Remote information
        local remote_branch="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"
        
        if [[ -n "${remote_url}" ]]; then
            printf "\n"
            if [[ -n "${https_url}" ]]; then
                display_info "Repository URL" "${https_url}" "fg_blue1"
            fi
            display_info "Remote URL" "${remote_url}" "fg_blue1"
            display_info "Upstream branch" "${remote_branch}" "fg_green1"
            
            # Get ahead/behind status
            local ahead_behind="$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)"
            if [[ -n "${ahead_behind}" ]]; then
                local ahead="$(echo "${ahead_behind}" | cut -f1)"
                local behind="$(echo "${ahead_behind}" | cut -f2)"
                
                if [[ "${ahead}" -gt 0 ]] && [[ "${behind}" -gt 0 ]]; then
                    display_info "Status" "${ahead} ahead, ${behind} behind" "fg_yellow3"
                elif [[ "${ahead}" -gt 0 ]]; then
                    display_info "Status" "${ahead} ahead" "fg_green1"
                elif [[ "${behind}" -gt 0 ]]; then
                    display_info "Status" "${behind} behind" "fg_red1"
                else
                    display_info "Status" "up to date" "fg_green1"
                fi
            fi
        fi

        # Working directory status
        local status_output="$(git status --porcelain 2>/dev/null)"
        local modified_count=0
        local added_count=0
        local deleted_count=0
        local untracked_count=0
        
        if [[ -n "${status_output}" ]]; then
            modified_count="$(echo "${status_output}" | grep -c "^.M" 2>/dev/null)"
            added_count="$(echo "${status_output}" | grep -c "^A" 2>/dev/null)"
            deleted_count="$(echo "${status_output}" | grep -c "^.D" 2>/dev/null)"
            untracked_count="$(echo "${status_output}" | grep -c "^??" 2>/dev/null)"
        fi
        
        printf "\n"
        if [[ -z "${status_output}" ]]; then
            display_info "Working directory" "clean" "fg_green1"
        else
            display_info "Working directory" "dirty" "fg_red1"
            if [[ "${modified_count}" -gt 0 ]]; then
                display_info "  Modified" "${modified_count}" "fg_yellow3"
            fi
            if [[ "${added_count}" -gt 0 ]]; then
                display_info "  Added" "${added_count}" "fg_green1"
            fi
            if [[ "${deleted_count}" -gt 0 ]]; then
                display_info "  Deleted" "${deleted_count}" "fg_red1"
            fi
            if [[ "${untracked_count}" -gt 0 ]]; then
                display_info "  Untracked" "${untracked_count}" "fg_cyan1"
            fi
        fi
    fi
}

