#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

if [ ${#DOT_LOCATION} -gt 0 ]; then
    export_path="${DOT_LOCATION}"
else
    export_path="~"
fi

if [ -f ${export_path}/dotfiles/exports ]; then
    source ${export_path}/dotfiles/exports
fi

unset export_path