# Forked from: joseph.tingiris@gmail.com
# 2022.11.09 - ducet8@outlook.com

# ls version sort
function llv() {
    ls -lFha $@ | sort -k 9 -V
}

# export -f llv