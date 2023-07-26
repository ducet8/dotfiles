# vim: ft=sh
# 2023.07.26 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P brew &>/dev/null && ! type -P $(brew --prefix)/opt/gnu-sed/libexec/gnubin/sed &>/dev/null; then
    return 0
fi

export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
