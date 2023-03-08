# vim: ft=sh
# 2023.03.08 - ducet8@outlook.com

# ls version sort
function llv() {
    ls -lFha $@ | sort -k 9 -V
}

