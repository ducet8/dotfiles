#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function list_running_apps() {
    osascript <<EOF
tell application "Finder"
get the name of every process whose visible is true
end tell
EOF
}

export -f list_running_apps