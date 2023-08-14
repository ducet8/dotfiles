# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

# TODO: Add ability to accept options
goto() {
   [[ ${BD_OS,,} == "darwin" ]] && tabname ${1}
   ssh ${1}
}
