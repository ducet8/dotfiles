# vim: ft=sh
# Forked from: Jess Frizelle
# 2025.09.01 - ducet8@outlook.com

# DNS lookup utility - shows all record types for a domain
#
if ! type -P dig &>/dev/null; then
    return 0
fi

diga() {
    local version="1.0.0"
    
    print_help() {
        local program="diga"
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf "DNS lookup utility - shows all record types for a domain\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s <domain>\n" "${program}"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\tShow this help\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s google.com\t\tShow all DNS records for google.com\n" "${program}"
            printf "\t%s github.io\t\tShow all DNS records for github.io\n" "${program}"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "DNS lookup utility - shows all record types for a domain\n\n"
            printf "USAGE:\n"
            printf "\t%s <domain>\n" "${program}"
            printf "OPTIONS:\n"
            printf "\t-h|--help\t\tShow this help\n"
            printf "EXAMPLES:\n"
            printf "\t%s google.com\t\tShow all DNS records for google.com\n" "${program}"
            printf "\t%s github.io\t\tShow all DNS records for github.io\n" "${program}"
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
    
    # Check for domain argument
    if [[ -z "${1}" ]]; then
        abort_with_message "Domain required. Use -h for help."
        return 1
    fi
    
    # Run dig command
    dig +nocmd "${1}" any +multiline +noall +answer
}

# Keep old function name for backwards compatibility
digga() {
    diga "$@"
}
