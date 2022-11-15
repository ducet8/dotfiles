# 2022.11.09 - ducet8@outlook.com

# TODO: Add ability to accept options
function goto() {
   [[ ${Os_Id,,} == "darwin" ]] && tabname ${1}
   ssh ${1}
}

# export -f goto