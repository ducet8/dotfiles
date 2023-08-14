# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`

json() {
	if [ -t 0 ]; then
		python -mjson.tool <<< "$*" | pygmentize -l javascript
	else # pipe
		python -mjson.tool | pygmentize -l javascript
	fi
}
