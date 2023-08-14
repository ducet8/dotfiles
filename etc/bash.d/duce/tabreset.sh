# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

tabreset() {
  echo -n -e "\033]6;1;bg;*;default\a"
}
