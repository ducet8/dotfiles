# vim: ft=sh
# 2023:08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

tabname() {
   printf "\e]1;$1\a"
}
