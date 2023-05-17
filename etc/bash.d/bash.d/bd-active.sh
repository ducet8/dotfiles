# bd-active.sh: display a debug message when bd is active (i.e. when this script gets sourced)

# Copyright (C) 2018-2023 Joseph Tingiris <joseph.tingiris@gmail.com>
# https://github.com/bash-d/bd/blob/main/LICENSE.md

#
# metadata
#

# bash.d: exports BD_ANSI_SH
# vim: ft=sh:ts=4:sw=4

#
# main
#

# prevent non-sourced execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (instead, 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

# bd source id
export BD_ACTIVE_SH="${BASH_SOURCE}"

# sample; put in an etc/bash.d directory to see if it's 'active'
type -t bd_debug | grep -q "function" && [ -n "${BD_DEBUG}" ] && bd_debug "${BASH_SOURCE} is active" 1
