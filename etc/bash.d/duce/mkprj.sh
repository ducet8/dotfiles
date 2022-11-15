# 2022.11.08 - ducet8@outlook.com

if [[ ${Os_Id,,} != "darwin" ]]; then
    return 0
fi

function mkprj() {
    mkdir ${HOME}/projects/${1}
    cp ${HOME}/projects/gitignore ${HOME}/projects/${1}/.gitignore
}
