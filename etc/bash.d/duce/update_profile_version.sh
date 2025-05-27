# vim: ft=sh
# 2025.05.27 - ducet8@outlook.com

update_profile_version() {
    local file="${BD_HOME}/dotfiles/bash_profile"
    local new_date="$(date +%Y.%m.%d)"
    
    # Use awk for more reliable text replacement
    awk -v new_date="${new_date}" '
    /^bash_profile_date=/ {
        sub(/bash_profile_date="[^"]*"/, "bash_profile_date=\"" new_date "\"")
        print
        next
    }
    { print }
    ' "${file}" > "${file}.tmp" && mv "${file}.tmp" "${file}"
}
