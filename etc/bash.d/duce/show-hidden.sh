# 2022.11.08 - ducet8@outlook.com

if [[ ${Os_Id,,} != "darwin" ]]; then
    return 0
fi

function show_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles TRUE
    killall Finder
}
