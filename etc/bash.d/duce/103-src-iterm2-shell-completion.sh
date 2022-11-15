# 2022.11.08 - ducet8@outlook.com

# iTerm2 Shell Integration

if [[ ${Os_Id,,} == "darwin" ]]; then
    if [[ -e "${DOT_LOCATION}/.iterm2_shell_integration.bash" ]]; then
        source "${DOT_LOCATION}/.iterm2_shell_integration.bash"
    fi
fi
