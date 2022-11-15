# 2022.11.08 - ducet8@outlook.com

if [[ ${Os_Id,,} != "darwin" ]]; then
    return 0
fi

function list_running_apps() {
    osascript <<EOF
tell application "Finder"
get the name of every process whose visible is true
end tell
EOF
}
