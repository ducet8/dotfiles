# 2022.12.20 - ducet8@outlook.com

if [ ${#BD_HOME} -gt 0 ]; then
    export_path="${BD_HOME}"
else
    export_path="~"
fi

if [ -f ${export_path}/dotfiles/exports ]; then
    source ${export_path}/dotfiles/exports
fi

unset export_path
