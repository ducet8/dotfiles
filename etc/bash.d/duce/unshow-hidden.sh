# 2022.12.19 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

function unshow_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles FALSE
    killall Finder
}
