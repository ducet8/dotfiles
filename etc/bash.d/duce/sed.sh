# vim: ft=sh
# 2024.06.03 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

if ! type -P brew &>/dev/null && ! type -P $(brew --prefix)/opt/gnu-sed/libexec/gnubin/sed &>/dev/null; then
    return 0
fi

#export PATH="/opt/homebrew/Cellar/gnu-sed/4.9/bin:$PATH"
export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
