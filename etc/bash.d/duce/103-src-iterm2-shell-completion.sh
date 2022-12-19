# 2022.12.19 - ducet8@outlook.com

# iTerm2 Shell Integration

if [[ ${BD_OS,,} == "darwin" ]]; then
    if [[ -e "${DOT_LOCATION}/.iterm2_shell_integration.bash" ]]; then
        source "${DOT_LOCATION}/.iterm2_shell_integration.bash"
    fi
fi
