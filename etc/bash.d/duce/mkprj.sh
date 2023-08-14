# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

mkprj() {
    mkdir ${HOME}/projects/${1}
    cp ${HOME}/projects/gitignore ${HOME}/projects/${1}/.gitignore
}
