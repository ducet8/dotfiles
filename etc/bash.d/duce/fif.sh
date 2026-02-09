# vim: ft=sh
# Forked from: joseph.tingiris@gmail.com
# 2026.02.09 - ducet8@outlook.com

# find file (ff) or find in file (fif)

fif() {
    local fif_version="2.0.0"
    
    print_help() {
        local program="fif"
        if [[ "${FUNCNAME[2]}" == "ff" ]]; then
            program="ff"
        fi
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${fif_version}"
            printf "Deep search utility for files and file contents\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s [directory] <search_term> [find_flags]\n" "${program}"
            printf "\t%s <search_term> [find_flags]\n" "${program}"
            bd_ansi fg_yellow3
            printf "DESCRIPTION:\n"
            bd_ansi reset
            if [[ "${program}" == "ff" ]]; then
                printf "\tSearch for files by filename pattern\n"
            else
                printf "\tfif: Search for content inside files\n"
                printf "\tff:  Search for files by filename pattern\n"
            fi
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-i"
            bd_ansi reset
            printf "\t\t\tCase-insensitive search (content search only)\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s \"function_name\"\t\t# Search for function_name in current directory\n" "${program}"
            printf "\t%s /src \"TODO\"\t\t# Search for TODO in /src directory\n" "${program}"
            printf "\t%s -i \"Error\"\t\t\t# Case-insensitive search for Error\n" "${program}"
            printf "\t%s \"*.log\" \"-mtime -1\"\t# Find log files modified in last day\n" "${program}"
        else
            printf "%s\t%s\n" "${program}" "${fif_version}"
            printf "Deep search utility for files and file contents\n\n"
            printf "USAGE:\n"
            printf "\t%s [directory] <search_term> [find_flags]\n" "${program}"
            printf "\t%s <search_term> [find_flags]\n" "${program}"
            printf "DESCRIPTION:\n"
            if [[ "${program}" == "ff" ]]; then
                printf "\tSearch for files by filename pattern\n"
            else
                printf "\tfif: Search for content inside files\n"
                printf "\tff:  Search for files by filename pattern\n"
            fi
            printf "OPTIONS:\n"
            printf "\t-i\t\t\tCase-insensitive search (content search only)\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "EXAMPLES:\n"
            printf "\t%s \"function_name\"\t\t# Search for function_name in current directory\n" "${program}"
            printf "\t%s /src \"TODO\"\t\t# Search for TODO in /src directory\n" "${program}"
            printf "\t%s -i \"Error\"\t\t\t# Case-insensitive search for Error\n" "${program}"
            printf "\t%s \"*.log\" \"-mtime -1\"\t# Find log files modified in last day\n" "${program}"
        fi
    }
    
    abort_with_message() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_red1
            printf "\n✗ aborting ... %s\n\n" "$*"
            bd_ansi reset
        else
            printf "\naborting ... %s\n\n" "$*"
        fi
        return 1
    }

    # Handle help flags first
    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
    esac

    # Parse arguments
    local case_insensitive=0
    local from='.'
    local string=""
    local find_flags=""
    
    # Check for -i flag
    if [[ "${1}" == "-i" ]]; then
        case_insensitive=1
        shift
    fi
    
    if [[ ! "${1}" ]]; then
        print_help
        return 1
    fi

    # Determine if first arg is directory or search term
    if [[ -d "${1}" ]]; then
        from="${1}"
        string="${2}"
        find_flags="${3}"
    else
        from='.'
        string="${1}"
        find_flags="${2}"
    fi

    if [[ -z "${string}" ]]; then
        print_help
        return 1
    fi

    # Set up platform-specific tools
    if [[ "${BD_OS}" == 'darwin' ]]; then
        local readlink_cmd='greadlink'
        local xargs_args='-0'
    else
        local readlink_cmd='readlink'
        local xargs_args='-0 -r --max-args=64 --max-procs=16'
    fi

    # Check dependencies
    local depends=('find' 'grep' "${readlink_cmd}" 'xargs')
    for depend in "${depends[@]}"; do
        if ! type -P "${depend}" &> /dev/null; then 
            abort_with_message "${depend} executable not found"
            return 1
        fi
    done

    # Save and set noglob to prevent glob expansion of * in find patterns
    local noglob_was_set=0
    if [[ -o noglob ]]; then
        noglob_was_set=1
    fi
    set -o noglob

    # Build exclusions
    local find_excludes=('.git' '.svn')

    local basename="${FUNCNAME[0]}"
    local find_exclude_files=(".${basename}-exclude" ".find-exclude")
    for find_exclude_file in "${find_exclude_files[@]}"; do
        if [[ -r "${find_exclude_file}" ]]; then
            readarray -t additional_excludes < <(grep -v '^#' "${find_exclude_file}")
            find_excludes+=("${additional_excludes[@]}")
        fi
    done

    local find_exclude_args=''
    local find_exclude_count=0
    for find_exclude in "${find_excludes[@]}"; do
        if [[ ${find_exclude_count} -gt 0 ]]; then
            find_exclude_args+=' -and'
        fi
        find_exclude_args+=" -not -iwholename */${find_exclude}/*"
        ((find_exclude_count++))
    done

    # Determine search mode
    local find_file=1  # false (content search by default)
    if [[ "${FUNCNAME[1]}" == 'ff' ]]; then
        find_file=0  # true (filename search)
    fi

    # Perform the search
    local resolved_from
    resolved_from=$(${readlink_cmd} -e "${from}") || {
        abort_with_message "cannot resolve path: ${from}"
        [[ ${noglob_was_set} -eq 0 ]] && set +o noglob
        return 1
    }

    if type bd_ansi &>/dev/null; then
        bd_ansi fg_cyan1
        if [[ ${find_file} -eq 0 ]]; then
            printf "🔍 Searching filenames for: %s\n" "${string}"
        else
            printf "🔍 Searching file contents for: %s%s\n" "${string}" "$([[ ${case_insensitive} -eq 1 ]] && echo " (case-insensitive)")"
        fi
        bd_ansi reset
    fi

    if [[ ${find_file} -eq 0 ]]; then
        # File name search
        LC_ALL=C find ${find_flags} "${resolved_from}"/ ${find_exclude_args} -and -name "*${string}*" 2> /dev/null
    else
        # Content search
        local grep_flags="-Fl"
        if [[ ${case_insensitive} -eq 1 ]]; then
            grep_flags="-Fli"
        fi
        LC_ALL=C find ${find_flags} "${resolved_from}"/ ${find_exclude_args} -type f -print0 2> /dev/null | \
            xargs ${xargs_args} grep ${grep_flags} "${string}" 2> /dev/null
    fi

    # Restore noglob to original state
    if [[ ${noglob_was_set} -eq 0 ]]; then
        set +o noglob
    fi
}

# Separate ff function for filename search
ff() {
    fif "$@"
}

