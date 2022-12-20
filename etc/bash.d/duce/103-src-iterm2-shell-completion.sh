# 2022.12.20 - ducet8@outlook.com

# iTerm2 Shell Integration

if [[ ${BD_OS,,} == "darwin" ]]; then
    if [[ -e "${BD_HOME}/.iterm2_shell_integration.bash" ]]; then
        source "${BD_HOME}/.iterm2_shell_integration.bash"
    fi
fi
