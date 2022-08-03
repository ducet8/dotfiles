#!/usr/bin/env bash

if [ ${#HOME} -gt 0 ]; then
    export_path="${HOME}"
else
    export_path="~"
fi
if [ -f ${export_path}/dotfiles/exports ]; then
    source ${export_path}/dotfiles/exports
fi
unset export_path