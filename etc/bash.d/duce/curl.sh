# vim: ft=sh
# 2023.11.22 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P brew &>/dev/null && ! type -P $(brew --prefix)/opt/curl/bin/curl &>/dev/null; then
    return 0
fi

export PATH="/opt/homebrew/opt/curl/bin:$PATH"
