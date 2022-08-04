#!/usr/bin/env bash

if [ ${#DOT_LOCATION} -gt 0 ]; then
    export_path="${DOT_LOCATION}"
else
    export_path="~"
fi
if [ -f ${export_path}/dotfiles/exports ]; then
    source ${export_path}/dotfiles/exports
fi
unset export_path