#!/usr/bin/env bash

function list_running_apps() {
    osascript <<EOF
tell application "Finder"
get the name of every process whose visible is true
end tell
EOF
}

export -f list_running_apps