# 2022.12.20 - ducet8@outlook.com

# Add tab completion for SSH hostnames based on ~/.ssh/config ignoring wildcards

if [[ ${BD_OS,,} == "darwin" ]]; then
    if [[ -e "${BD_HOME}/.ssh/config" ]]; then
        complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" goto scp sftp ssh
    fi
fi
