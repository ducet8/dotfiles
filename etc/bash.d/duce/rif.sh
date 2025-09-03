# vim: ft=sh
# Forked from: joseph.tingiris@gmail.com
# 2025.09.03 - ducet8@outlook.com

# replace in file(s)

rif() {
    local rif_version="2.0.0"
    
    print_help() {
        local program="rif"
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${rif_version}"
            printf "Replace text in files recursively\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s <from_text> <to_text>\n" "${program}"
            bd_ansi fg_yellow3
            printf "DESCRIPTION:\n"
            bd_ansi reset
            printf "\tSearches current directory recursively for files containing <from_text>\n"
            printf "\tand replaces all occurrences with <to_text>\n"
            printf "\tExcludes .git and .svn directories\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-f|--file <file>"
            bd_ansi reset
            printf "\tTarget specific file instead of searching recursively\n"
            bd_ansi fg_blue1
            printf "\t-p|--prompt"
            bd_ansi reset
            printf "\t\tPrompt for confirmation before modifying each file\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s \"oldFunction\" \"newFunction\"\t# Replace function name\n" "${program}"
            printf "\t%s \"TODO\" \"DONE\"\t\t\t# Replace TODO markers\n" "${program}"
            printf "\t%s -f script.js \"var\" \"let\"\t\t# Replace only in specific file\n" "${program}"
            printf "\t%s -p \"oldAPI\" \"newAPI\"\t\t# Prompt before each file\n" "${program}"
            bd_ansi fg_yellow3
            printf "WARNING:\n"
            bd_ansi fg_red1
            printf "\tThis modifies files in place. Use with caution!\n"
            bd_ansi reset
        else
            printf "%s\t%s\n" "${program}" "${rif_version}"
            printf "Replace text in files recursively\n\n"
            printf "USAGE:\n"
            printf "\t%s <from_text> <to_text>\n" "${program}"
            printf "DESCRIPTION:\n"
            printf "\tSearches current directory recursively for files containing <from_text>\n"
            printf "\tand replaces all occurrences with <to_text>\n"
            printf "\tExcludes .git and .svn directories\n"
            printf "OPTIONS:\n"
            printf "\t-f|--file <file>\tTarget specific file instead of searching recursively\n"
            printf "\t-p|--prompt\t\tPrompt for confirmation before modifying each file\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "EXAMPLES:\n"
            printf "\t%s \"oldFunction\" \"newFunction\"\t# Replace function name\n" "${program}"
            printf "\t%s \"TODO\" \"DONE\"\t\t\t# Replace TODO markers\n" "${program}"
            printf "\t%s -f script.js \"var\" \"let\"\t\t# Replace only in specific file\n" "${program}"
            printf "\t%s -p \"oldAPI\" \"newAPI\"\t\t# Prompt before each file\n" "${program}"
            printf "WARNING:\n"
            printf "\tThis modifies files in place. Use with caution!\n"
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
    
    detect_sed_type() {
        # Test if sed supports GNU-style --version
        if sed --version &>/dev/null; then
            echo "gnu"
        else
            echo "bsd"
        fi
    }

    # Parse options
    local target_file=""
    local prompt_mode=0
    
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                print_help
                return 0
                ;;
            -f|--file)
                if [[ -z "${2}" ]]; then
                    abort_with_message "Option -f|--file requires a filename"
                    return 1
                fi
                target_file="${2}"
                shift 2
                ;;
            -p|--prompt)
                prompt_mode=1
                shift
                ;;
            -*)
                abort_with_message "Unknown option: ${1}"
                return 1
                ;;
            *)
                break
                ;;
        esac
    done

    # Validate arguments
    if [[ -z "${1}" ]] || [[ -z "${2}" ]]; then
        print_help
        return 1
    fi

    local replace_from="${1}"
    local replace_to="${2}"
    local sed_type
    local files_found=0
    local files_modified=0
    local files_failed=0

    # Detect sed type for proper in-place editing
    sed_type=$(detect_sed_type)

    # Escape special characters for sed
    replace_from="${replace_from//\*/\\*}"
    replace_to="${replace_to//\*/\\*}"

    if type bd_ansi &>/dev/null; then
        bd_ansi fg_cyan1
        printf "🔍 Searching for files containing: %s\n" "${1}"
        bd_ansi reset
    fi

    # Determine files to process
    local found_files
    if [[ -n "${target_file}" ]]; then
        # Single file mode
        if [[ ! -f "${target_file}" ]]; then
            abort_with_message "File not found: ${target_file}"
            return 1
        fi
        if ! grep -q "${1}" "${target_file}" 2>/dev/null; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_yellow3
                printf "ℹ️  No matches found in: %s\n" "${target_file}"
                bd_ansi reset
            else
                printf "ℹ️  No matches found in: %s\n" "${target_file}"
            fi
            return 0
        fi
        found_files="${target_file}"
    else
        # Recursive search mode
        found_files=$(find . -type f ! -wholename "*.git*" -and ! -wholename "*.svn*" -print0 | \
                      xargs -0 -r grep -l "${1}" 2>/dev/null)
        
        if [[ -z "${found_files}" ]]; then
            return 0
        fi
    fi
    
    while IFS= read -r file; do
        if [[ -z "${file}" ]]; then continue; fi
        
        ((files_found++))
        
        # Prompt for confirmation if in prompt mode
        if [[ ${prompt_mode} -eq 1 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_yellow3
                printf "Replace '%s' → '%s' in: %s? [y/N] " "${1}" "${2}" "${file}"
                bd_ansi reset
            else
                printf "Replace '%s' → '%s' in: %s? [y/N] " "${1}" "${2}" "${file}"
            fi
            read -r response
            if [[ "${response}" != "y" && "${response}" != "Y" && "${response}" != "yes" && "${response}" != "Yes" && "${response}" != "YES" ]]; then
                if type bd_ansi &>/dev/null; then
                    bd_ansi fg_cyan1
                    printf "⏭️  Skipped: %s\n" "${file}"
                    bd_ansi reset
                else
                    printf "⏭️  Skipped: %s\n" "${file}"
                fi
                continue
            fi
        fi
        
        # Perform replacement based on sed type
        local sed_result
        if [[ "${sed_type}" == "gnu" ]]; then
            sed_result=$(sed -i "s/${replace_from}/${replace_to}/g" "${file}" 2>&1)
        else
            # BSD sed requires backup extension, we use empty string for no backup
            sed_result=$(sed -i '' "s/${replace_from}/${replace_to}/g" "${file}" 2>&1)
        fi
        
        if [[ $? -eq 0 ]]; then
            ((files_modified++))
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ "
                bd_ansi reset
                printf "Replaced '%s' → '%s' in: %s\n" "${1}" "${2}" "${file}"
            else
                printf "✓ Replaced '%s' → '%s' in: %s\n" "${1}" "${2}" "${file}"
            fi
        else
            ((files_failed++))
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ FAILED to replace in: %s\n" "${file}"
                bd_ansi reset
            else
                printf "✗ FAILED to replace in: %s\n" "${file}"
            fi
            if [[ -n "${sed_result}" ]]; then
                printf "  Error: %s\n" "${sed_result}"
            fi
        fi
    done <<< "${found_files}"

    # Summary
    if type bd_ansi &>/dev/null; then
        bd_ansi fg_cyan1
        printf "\n📊 Summary: "
        bd_ansi reset
        printf "Found %d files, modified %d files" "${files_found}" "${files_modified}"
        if [[ ${files_failed} -gt 0 ]]; then
            bd_ansi fg_red1
            printf ", %d failed" "${files_failed}"
            bd_ansi reset
        fi
        printf "\n"
    else
        printf "\nSummary: Found %d files, modified %d files" "${files_found}" "${files_modified}"
        if [[ ${files_failed} -gt 0 ]]; then
            printf ", %d failed" "${files_failed}"
        fi
        printf "\n"
    fi

    return 0
}
