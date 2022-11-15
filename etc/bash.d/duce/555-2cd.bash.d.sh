# 2022.11.08 - ducet8@outlook.com

if [[ ${Os_Id,,} != "darwin" ]]; then
    return 0
fi

function 2cd() {
    if [[ $# == 0 ]]; then
        builtin cd ~ && ls -ltr
    elif [[ $@ == '-' ]]; then
        builtin cd - && ls -ltr
    elif [[ -d $@ ]]; then
        builtin cd $@ && ls -ltr
    else
        bd_ansi fg_red
        echo $@ directory not found!!!
        bd_ansi reset
    fi
}
