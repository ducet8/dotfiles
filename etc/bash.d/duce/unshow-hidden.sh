# 2022.11.08 - ducet8@outlook.com

if [[ ${Os_Id,,} != "darwin" ]]; then
    return 0
fi

function unshow_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles FALSE
    killall Finder
}
