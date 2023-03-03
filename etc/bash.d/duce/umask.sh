# Forked from: joseph.tingiris@gmail.com
# 2023.03.03 - ducet8@outlook.com

if [ "${USER}" != "root" ]; then
    umask u+rw,g-rwx,o-rwx
fi
