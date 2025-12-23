# vim: ft=sh
# 2025.12.23 - ducet8@outlook.com

update-profile-version() {
    local version="1.1.0"
    
    print_help() {
        local program="update-profile-version"
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf "Update bash_profile date to current date\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s\n" "${program}"
            bd_ansi fg_yellow3
            printf "DESCRIPTION:\n"
            bd_ansi reset
            printf "\tUpdates the bash_profile_date variable in bash_profile to today's date\n"
            printf "\tUses YYYY.MM.DD format\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s\t\t\t# Updates date to today\n" "${program}"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "Update bash_profile date to current date\n\n"
            printf "USAGE:\n"
            printf "\t%s\n" "${program}"
            printf "DESCRIPTION:\n"
            printf "\tUpdates the bash_profile_date variable in bash_profile to today's date\n"
            printf "\tUses YYYY.MM.DD format\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "EXAMPLES:\n"
            printf "\t%s\t\t\t# Updates date to today\n" "${program}"
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
    
    # Handle help flags and invalid arguments
    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
        "")
            # No arguments - proceed with normal operation
            ;;
        *)
            # Any other argument is invalid
            print_help
            return 1
            ;;
    esac
    
    # Check if rif function is available
    if ! type rif &>/dev/null; then
        abort_with_message "rif function not available - ensure rif.sh is sourced"
        return 1
    fi
    
    local file="${BD_HOME}/dotfiles/bash_profile"
    local new_date="$(date +%Y.%m.%d)"

    # Extract the current date from the file
    local old_date="$(grep -o 'bash_profile_date="[^"]*"' "${file}" | cut -d'"' -f2)"

    if [[ -z "${old_date}" ]]; then
        abort_with_message "Could not find bash_profile_date in ${file}"
        return 1
    fi

    local old_pattern="bash_profile_date=\"${old_date}\""
    local new_pattern="bash_profile_date=\"${new_date}\""

    # Use rif to replace the date with literal text
    rif -f "${file}" "${old_pattern}" "${new_pattern}"
}
