# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

# ls version sort
llv() {
    ls -lFha $@ | sort -k 9 -V
}
