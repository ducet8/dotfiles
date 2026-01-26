# vim: ft=sh
# 2026.01.26 - ducet8@outlook.com
 
# iTerm2 tmux integration helper

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

# Check if running in iTerm2
if [[ -z "${ITERM_SESSION_ID}" ]] && [[ -z "${ITERM_PROFILE}" ]] && [[ "${TERM_PROGRAM}" != "iTerm.app" ]]; then
    return 0
fi

tmux-cc() {
    local version="1.1.0"

    print_help() {
        local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')

        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "%s" "${program}"
            bd_ansi reset
            printf "\t%s\n" "${version}"
            printf "Smart tmux wrapper that uses -CC integration mode in iTerm2\n\n"
            bd_ansi fg_yellow3
            printf "DESCRIPTION:\n"
            bd_ansi reset
            printf "\tAutomatically uses 'tmux -CC' integration mode when running in iTerm2.\n"
            printf "\tThis provides native macOS window management while tmux persists in the\n"
            printf "\tbackground, enabling full iTerm2 features and shell integration.\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\t%s [tmux-options]\n" "${program}"
            printf "\t%s attach [-t session-name]\n" "${program}"
            printf "\t%s new-session [-s session-name]\n\n" "${program}"
            bd_ansi fg_yellow3
            printf "BENEFITS:\n"
            bd_ansi reset
            printf "\t• Native macOS UI (Cmd+T, Cmd+W, Cmd+1/2/3)\n"
            printf "\t• Full iTerm2 features (scrollback, search)\n"
            printf "\t• Shell integration works (not available in regular tmux)\n"
            printf "\t• No tmux prefix key needed for window management\n"
            printf "\t• Session persistence (detach with Esc, reattach with '%s attach')\n\n" "${program}"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\t%s\t\t\t\t# Start new integrated session\n" "${program}"
            printf "\t%s attach\t\t\t# Attach to last session\n" "${program}"
            printf "\t%s attach -t work\t\t# Attach to 'work' session\n" "${program}"
            printf "\t%s new-session -s dev\t\t# Create 'dev' session\n" "${program}"
            printf "\t%s ls\t\t\t\t# List sessions\n" "${program}"
            printf "\t%s kill-session -t work\t# Kill 'work' session\n\n" "${program}"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "\t\t\tShow this help\n"
        else
            printf "%s\t%s\n" "${program}" "${version}"
            printf "Smart tmux wrapper that uses -CC integration mode in iTerm2\n\n"
            printf "DESCRIPTION:\n"
            printf "\tAutomatically uses 'tmux -CC' integration mode when running in iTerm2.\n"
            printf "\tThis provides native macOS window management while tmux persists in the\n"
            printf "\tbackground, enabling full iTerm2 features and shell integration.\n\n"
            printf "USAGE:\n"
            printf "\t%s [tmux-options]\n" "${program}"
            printf "\t%s attach [-t session-name]\n" "${program}"
            printf "\t%s new-session [-s session-name]\n\n" "${program}"
            printf "BENEFITS:\n"
            printf "\t• Native macOS UI (Cmd+T, Cmd+W, Cmd+1/2/3)\n"
            printf "\t• Full iTerm2 features (scrollback, search)\n"
            printf "\t• Shell integration works (not available in regular tmux)\n"
            printf "\t• No tmux prefix key needed for window management\n"
            printf "\t• Session persistence (detach with Esc, reattach with '%s attach')\n\n" "${program}"
            printf "EXAMPLES:\n"
            printf "\t%s\t\t\t\t# Start new integrated session\n" "${program}"
            printf "\t%s attach\t\t\t# Attach to last session\n" "${program}"
            printf "\t%s attach -t work\t\t# Attach to 'work' session\n" "${program}"
            printf "\t%s new-session -s dev\t\t# Create 'dev' session\n" "${program}"
            printf "\t%s ls\t\t\t\t# List sessions\n" "${program}"
            printf "\t%s kill-session -t work\t# Kill 'work' session\n\n" "${program}"
            printf "OPTIONS:\n"
            printf "\t-h|--help\t\t\tShow this help\n"
        fi
    }

    # Handle help flags
    case "${1}" in
        -h|--help)
            print_help
            return 0
            ;;
    esac

    # Determine which tmux binary to use
    local tmux_bin="${TMUX_BIN:-$(type -P tmux 2>/dev/null)}"

    if [[ -z "${tmux_bin}" ]] || [[ ! -x "${tmux_bin}" ]]; then
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_red1
            printf "✗ tmux not found or not executable\n"
            bd_ansi reset
        else
            printf "✗ tmux not found or not executable\n"
        fi
        return 1
    fi

    # Build base tmux command
    local tmux_cmd="${tmux_bin}"

    # Add config if available
    if [[ -r "${BD_HOME}/.tmux.conf" ]]; then
        tmux_cmd="${tmux_bin} -f ${BD_HOME}/.tmux.conf -u"
    fi

    # Determine if this command should use -CC integration mode
    # Only attach/new-session commands need -CC; other commands (ls, kill-session, etc.) should not use it
    needs_cc_mode() {
        local cmd="${1}"
        case "${cmd}" in
            # Commands that create or attach to sessions need -CC
            attach|attach-session|a|at)
                return 0
                ;;
            new|new-session)
                return 0
                ;;
            # No argument means new session
            "")
                return 0
                ;;
            # All other commands should run without -CC
            *)
                return 1
                ;;
        esac
    }

    # Add -CC flag only for session-attaching commands and only if not already in a tmux session
    if [[ -z "${TMUX}" ]] && needs_cc_mode "${1}"; then
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_cyan1
            printf "→ Using iTerm2 tmux integration mode\n"
            bd_ansi reset
        fi
        tmux_cmd="${tmux_cmd} -CC"
    fi

    # Execute tmux with all arguments, unsetting variables as in original tmux.sh
    (unset BASHRCSOURCED BD_ID && eval "${tmux_cmd}" "$@")
}
