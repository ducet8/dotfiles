# 2022.12.19 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

function use() {
    MATCHES=$(ls /Applications | grep -i "$@" | wc -l)
    if [[ MATCHES -eq 1 ]]; then
        APP=$(ls /Applications | grep -i "$@" | awk -F.app '{print $1}')
        osascript -e "tell app \"${APP}\" to activate"
    elif [[ MATCHES -eq 0 ]]; then
        printf "No applications were found matching $@\n"
    else
        printf "Too many applications were found matching $@.\n"
        ls /Applications | grep -i "$@"
        printf "\nPlease be more specific.\n"
    fi
}
