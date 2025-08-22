# vim: ft=sh
# 2025.08.22 - ducet8@outlook.com

if [[ ${BD_OS,,} == "darwin" ]]; then
    if [[ -r ${HOME}/.cargo/env ]] && [[ -f ${HOME}/.cargo/env ]]; then
        source ${HOME}/.cargo/env
    fi
fi
