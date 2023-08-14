# vim: ft=sh
# 2023.08.11 - ducet8@outlook.com

loc() {
    if ! type bd_ansi &>/dev/null; then
	echo "bd_ansi missing...loc exiting"
	return 1
    fi
    local loc_version="1.0.0"

    local usage="$(bd_ansi fg_blue1)loc$(bd_ansi reset)\t${loc_version}\nCounts the lines in files of a certain type\n\n$(bd_ansi fg_yellow3)USAGE:\n$(bd_ansi reset)\tloc [-d|--directory] [-v exclude_filetypes] [-d directory] [-r] [-h] <-a|filetype>\n$(bd_ansi fg_yellow3)ARGS:\n$(bd_ansi fg_blue1)\t<filetype>                $(bd_ansi reset)Filetype to count lines in - not required if -a is passed\n$(bd_ansi fg_yellow3)OPTIONS:\n$(bd_ansi fg_blue1)\t-h|--help                 $(bd_ansi reset)Displays this help\n$(bd_ansi fg_blue1)\t-a|--all                  $(bd_ansi reset)Count lines in all filetypes\n$(bd_ansi fg_blue1)\t-d|--directory            $(bd_ansi reset)Specify the directory to search (default: current directory)\n$(bd_ansi fg_blue1)\t-r|--recursive            $(bd_ansi reset)Enable recursive searching\n$(bd_ansi fg_blue1)\t-v|--exlude <ft> <ft>     $(bd_ansi reset)Exclude specific filetypes from counting\n\n"

    if [ $# -lt 1 ]; then
        printf "${usage}"
        return 1
    fi

    local directory='.'
    local exclude_filetypes=()
    local filenames=()
    local find_command=''
    local ft_supplied=1
    local line_counts=()
    local max_filename_length=0
    local recursive=''
    local total_lines=0

    while [ $# -gt 0 ]; do
        case "${1}" in
            -h|--help)
                printf "${usage}"
                return 0
                ;;

            -a|--all)
                find_command="find ${directory}"
		ft_supplied=0
                [ -n "${recursive}" ] && find_command+=" -name '*'"
                find_command+=' -type f'
		shift
                ;;

            -v|--exclude)
		shift
                while [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; do
                    exclude_filetypes+=("$1")
                    shift
                done
                ;;

            -d|--directory)
                shift
                if [ $# -gt 0 ] && [ "${1:0:1}" != '-' ]; then
                    directory="${1%/}"
                    shift
                else
                    echo 'Error: -d flag requires a directory argument.'
                    return 1
                fi
                ;;

            -r|--recursive)
                recursive='-r'
                shift
                ;;

            *)
		if [ ${ft_supplied} -eq 1 ]; then
		    ft_supplied=0

                    local find_command="find ${directory}"
                    [ -n "${recursive}" ] && find_command+=" -name '*'"
                    find_command+=" -type f -name '*.${1}'"
                  
                    if [ -z "$(eval "${find_command}" | head -n 1)" ]; then
                        echo "Error: No files found with the filetype: ${1}"
                        return 1
                    fi
                fi
		shift
                ;;
        esac
    done

    if [ ${ft_supplied} -eq 1 ]; then
        echo 'Error: Filetype argument is required.'
        return 1
    fi

    if [ -z "${exclude_filetypes}" ] || ! [[ " ${exclude_filetypes[@]} " =~ " ${1} " ]]; then
	local lines
        while IFS= read -r file; do
            lines=$(wc -l < "${file}")
            total_lines=$((total_lines + lines))
            filenames+=("${file}")
            line_counts+=("${lines}")
            filename_length=${#file}
            [ "${filename_length}" -gt "${max_filename_length}" ] && max_filename_length=${filename_length}
        done < <(eval "${find_command}")
	unset file
    fi

    for ((i = 0; i < ${#filenames[@]}; i++)); do
	    printf "$(bd_ansi fg_blue1)%-${max_filename_length}s  $(bd_ansi fg_yellow3)%d\n$(bd_ansi reset)" "${filenames[i]}" "${line_counts[i]}"
    done

    printf "Total Lines:\t$(bd_ansi fg_yellow3)%d\n$(bd_ansi reset)" "${total_lines}"
}
