# 2022.12.19 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

function tabreset() {
  echo -n -e "\033]6;1;bg;*;default\a"
}
