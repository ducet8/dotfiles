# vim: ft=sh
# 2023.10.11 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

did() {
    local did_version="1.0.0-a"
    local task="${1}"
    local today=$(date '+%Y-%m-%d')
    local accomplishments="${HOME}/Documents/daily_accomplishments.md"

    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "did"
            bd_ansi reset
            printf "\t${did_version}\n"
            printf "Record your daily accomplishments in a Markdown file, organized by date.\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\tdid [OPTIONS] <task>\n"
            bd_ansi fg_yellow3
            printf "OPTIONS:\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "        Displays this help\n"
            bd_ansi fg_yellow3
            printf "ARGUMENTS:\n"
            bd_ansi fg_blue1
            printf "\t<task>"
            bd_ansi reset
            printf "           A brief description of what you accomplished\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\tdid 'Completed a challenging task'\n"
            printf "\tdid 'Met with the team to discuss project goals'\n"
        else
            printf "did\t${did_version}\n"
            printf "Record your daily accomplishments in a Markdown file, organized by date.\n\n"
            printf "Usage:\n"
            printf "\tdid [OPTIONS] <task>\n"
            printf "OPTIONS:\n"
            printf "\t-h|--help        Displays this help\n"
            printf "ARGUMENTS:\n"
            printf "\t<task>           A brief description of what you accomplished\n"
            printf "EXAMPLES:\n"
            printf "\tdid 'Completed a challenging task'\n"
            printf "\tdid 'Met with the team to discuss project goals'\n"
        fi
    }

    if [ $# -ne 1 ]; then
        print_help
        return 1
    fi

    case "$1" in
        -h|--help)
            print_help
            ;;
        *)
            # Check if daily_accomplishments.md exists, and create it if not
            if [ ! -e "${accomplishments}" ]; then
                echo "Creating ${accomplishments}" && echo
                echo "# Daily Accomplishments" > "${accomplishments}"
            fi

            # Check if the date already exists in the Markdown file
            if ! grep -q "## ${today}" "${accomplishments}"; then
                # If the date does not exist, append it to the Markdown file
                echo -e "## ${today}\n- ${task}" >> "${accomplishments}"

                echo "Added to ${accomplishments}:"
                echo "## ${today}"
                echo "- ${task}"
            else
                # If the date already exists, only append the task as a new list item
                echo "- ${task}" >> "${accomplishments}"

                echo "Added to ${accomplishments} under existing date:"
                echo "- ${task}"
            fi
            ;;
    esac
}
