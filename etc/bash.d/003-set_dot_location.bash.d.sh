#!/usr/bin/env bash

if [[ -z "${SUDO_USER}" ]]; then
    export DOT_LOCATION="${HOME}"
else
    if [[ ${Os_Id} == "macos" ]]; then
        export DOT_LOCATION="$(finger ${SUDO_USER} | awk '/^Directory/ {print $2}')"
    else
        export DOT_LOCATION="$(cat /etc/passwd | grep -i "${SUDO_USER}" | cut -d: -f6)"
    fi
fi

if [[ -z "${DOT_LOCATION}" ]]; then
    elog alert "DOT_LOCATION did not get set"
fi