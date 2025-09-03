# vim: ft=sh
# 2025.09.03 - ducet8@outlook.com

if ! type -P tree &>/dev/null; then
    return 0
fi

tre() {
	local version="1.0.0"
	
	print_help() {
		local program="tre"
		
		if type bd_ansi &>/dev/null; then
			bd_ansi fg_blue1
			printf "%s" "${program}"
			bd_ansi reset
			printf "\t%s\n" "${version}"
			printf "Tree with enhanced display using bat or less\n\n"
			bd_ansi fg_yellow3
			printf "USAGE:\n"
			bd_ansi reset
			printf "\t%s [options] [directory]\n" "${program}"
			bd_ansi fg_yellow3
			printf "OPTIONS:\n"
			bd_ansi fg_blue1
			printf "\t-h|--help"
			bd_ansi reset
			printf "\t\tShow this help\n"
			bd_ansi fg_blue1
			printf "\t[tree options]"
			bd_ansi reset
			printf "\tAll tree command options are supported\n\n"
			bd_ansi fg_yellow3
			printf "EXAMPLES:\n"
			bd_ansi reset
			printf "\t%s\t\t\tShow current directory\n" "${program}"
			printf "\t%s /usr/local\t\tShow /usr/local directory\n" "${program}"
			printf "\t%s -L 2\t\t\tLimit to 2 levels deep\n" "${program}"
		else
			printf "%s\t%s\n" "${program}" "${version}"
			printf "Tree with enhanced display using bat or less\n\n"
			printf "USAGE:\n"
			printf "\t%s [options] [directory]\n" "${program}"
			printf "OPTIONS:\n"
			printf "\t-h|--help\t\tShow this help\n"
			printf "\t[tree options]\t\tAll tree command options are supported\n\n"
			printf "EXAMPLES:\n"
			printf "\t%s\t\t\tShow current directory\n" "${program}"
			printf "\t%s /usr/local\t\tShow /usr/local directory\n" "${program}"
			printf "\t%s -L 2\t\t\tLimit to 2 levels deep\n" "${program}"
		fi
	}
	
	# Handle help flags
	case "${1}" in
		-h|--help)
			print_help
			return 0
			;;
	esac
	
	if type bat &>/dev/null; then
		tree -aC -I '.git' --dirsfirst "$@" | bat --paging=auto --style=plain
	else
		tree -aC -I '.git' --dirsfirst "$@" | less -FRNX
	fi
}
