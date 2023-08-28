# vim: ft=sh
# 2023.08.28 - ducet8@outlook.com

update_profile_version() {
    local file="${BD_HOME}/dotfiles/bash_profile"
    local current_line="$(grep "local bash_profile_date=\"" "${file}")"
    local new_line="local bash_profile_date=\"$(date +%Y.%m.%d), ducet8@outlook.com\""
    sed -i '' "s/${current_line}/${new_line}/" "${file}"
}
