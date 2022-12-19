# 2022.12.19 - ducet8@outlook.com

# TODO: Add ability to accept options
function goto() {
   [[ ${BD_OS,,} == "darwin" ]] && tabname ${1}
   ssh ${1}
}

