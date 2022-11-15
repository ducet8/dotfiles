# 2022.11.08 - ducet8@outlook.com

# Add tab completion for SSH hostnames based on ~/.ssh/config ignoring wildcards

if [[ ${Os_Id,,} == "darwin" ]]; then
    if [[ -e "${DOT_LOCATION}/.ssh/config" ]]; then
        complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" goto scp sftp ssh
    fi
fi
