# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

2cd() {
    ls_cmd="$(alias ll | awk -F= '{print $2}' | sed -e s/\'//g)"
    if [[ $# == 0 ]]; then
        builtin cd ~ && ${ls_cmd}
    elif [[ $@ == '-' ]]; then
        builtin cd - && ${ls_cmd}
    elif [[ -d $@ ]]; then
        builtin cd $@ && ${ls_cmd}
    else
        bd_ansi fg_red
        echo $@ directory not found!!!
        bd_ansi reset
    fi
}
