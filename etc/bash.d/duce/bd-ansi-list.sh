# 2022.11.09 - ducet8@outlook.com

if ! declare -F | grep bd_ansi &>/dev/null; then
    return 0
fi

function bd_ansi_list {
    colors=( $(typeset -f bd_ansi | grep fg_ | grep -v '|' | grep -v default | awk -F_ '{print $2}'| rev | cut -c3- | rev | sort -u) )
    printf %9s
    for (( num=1; num<=${#colors[@]}; num++ )); do 
        printf %2s${num}%6s
    done
    printf '\n'
    unset num

    for color in ${colors[@]}; do 
        printf ${color}%$(( 10 - $(echo ${color} | wc -c) ))s
        for (( num=1; num<=${#colors[@]}; num++ )); do 
            bd_ansi fg_${color}${num}
            printf 'hello    '
            bd_ansi reset
        done
        printf '\n'
    done

    unset colors color num
}
