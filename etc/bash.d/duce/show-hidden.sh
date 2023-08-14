# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

show_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles TRUE
    killall Finder
}
