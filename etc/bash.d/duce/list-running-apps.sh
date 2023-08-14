# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

list_running_apps() {
    osascript <<EOF
tell application "Finder"
get the name of every process whose visible is true
end tell
EOF
}
