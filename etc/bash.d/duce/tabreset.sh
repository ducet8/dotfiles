# 2022.11.08 - ducet8@outlook.com

if [[ ${Os_Id,,} != "darwin" ]]; then
    return 0
fi

function tabreset() {
  echo -n -e "\033]6;1;bg;*;default\a"
}
