# Forked from: joseph.tingiris@gmail.com
# 2022.11.07 - ducet8@outlook.com

# output more verbose messages based on a verbosity level set in the environment or a specific file

# Set Verbose variables
Verbose_Pad_Left=11
Verbose_Pad_Right=50

# Allow local overwriting of verbosity
for verbose_file in "${User_Dir}/.verbose" "${User_Dir}/.bashrc.verbose"; do
    if [ -r "${verbose_file}" ]; then
        # get digits only from the first line; if they're not digits then set verbosity to one
        export Verbose=$(grep -m1 "^[0-9]*$" "${verbose_file}" 2> /dev/null)
        if [ ${#Verbose} -gt 0 ]; then
            break
        fi
    fi
done
unset verbose_file

function verbose() {
    # verbose level is usually the last argument
    local verbose_arguments=($@)

    local -i verbose_color
    local verbose_level verbose_message

    local -i verbosity

    # if these values are set with an integer that will be honored, otherwise a verbosity value of 1 will be set
    if [[ ${Verbose} =~ ^[0-9]+$ ]]; then
        verbosity=${Verbose}
    else
        if [[ ${VERBOSE} =~ ^[0-9]+$ ]]; then
            verbosity=${VERBOSE}
        else
            verbosity=1
        fi
    fi

    if [ ${#2} -gt 0 ]; then
        verbose_message="${verbose_arguments[@]}" # preserve verbose_arguments
        verbose_level=${verbose_arguments[${#verbose_arguments[@]}-1]}
        if [[ ${verbose_level} =~ ^[0-9]+$ ]]; then
            # remove the last (integer) element (verbose_level)
            verbose_message="${verbose_message% *}"
        else
            verbose_level=""
        fi
    else
        verbose_message="${1}"
        verbose_level=""
    fi

    # 0 EMERGENCY (unusable), 1 ALERT, 2 CRIT(ICAL), 3 ERROR, 4 WARN(ING), 5 NOTICE, 6 INFO(RMATIONAL), 7 DEBUG

    local verbose_message_upper

    if [ ${BASH_VERSINFO} -ge 4 ]; then
        verbose_message_upper="${verbose_message^^}"
    else
        verbose_message_upper=$(echo "${verbose_message}" | tr '[:lower:]' '[:upper:]')
    fi

    # convert verbose_message to uppercase & check for presence of keywords
    if [[ "${verbose_message_upper}" == *"ALERT"* ]]; then
        if [ ${#verbose_level} -eq 0 ]; then
            verbose_level=1
        fi
    else
        if [[ "${verbose_message_upper}" == *"CRIT"* ]]; then
            if [ ${#verbose_level} -eq 0 ]; then
                verbose_level=1
            fi
        else
            if [[ "${verbose_message_upper}" == *"ERROR"* ]]; then
                if [ ${#verbose_level} -eq 0 ]; then
                    verbose_level=1
                fi
            else
                if [[ "${verbose_message_upper}" == *"WARN"* ]]; then
                    if [ ${#verbose_level} -eq 0 ]; then
                        verbose_level=3
                    fi
                else
                    if [[ "${verbose_message_upper}" == *"NOTICE"* ]]; then
                        if [ ${#verbose_level} -eq 0 ]; then
                            verbose_level=2
                        fi
                    else
                        if [[ "${verbose_message_upper}" == *"INFO"* ]]; then
                            if [ ${#verbose_level} -eq 0 ]; then
                                verbose_level=4
                            fi
                        else
                            if [[ "${verbose_message_upper}" == *"DEBUG"* ]]; then
                                if [ ${#verbose_level} -eq 0 ]; then
                                    verbose_level=8
                                fi
                            else
                                if [ ${#verbose_level} -eq 0 ]; then
                                    verbose_level=0
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    if [ ${#verbose_level} -eq 0 ] || [ ${verbose_level} -eq 0 ]; then
        return # hide
    fi

    if [ ${verbose_level} -gt ${verbosity} ]; then
        return # hide
    fi

    local verbose_level_prefix

    if [[ "${Verbose_Level_Prefix}" =~ ^(0|on|true)$ ]]; then
        verbose_level_prefix=0
    else
        verbose_level_prefix=1
    fi

    if [ ${verbose_level} -eq 1 ]; then
        verbose_color=1
        if [ ${verbose_level_prefix} -eq 0 ] && [[ "${verbose_message_upper}" != *"ALERT"* ]]; then
            verbose_message="ALERT: ${verbose_message}"
        fi

        if [ ${verbose_level_prefix} -eq 0 ] &&  [[ "${verbose_message_upper}" != *"CRIT"* ]]; then
            verbose_message="CRITICAL: ${verbose_message}"
        fi

        if [ ${verbose_level_prefix} -eq 0 ] &&  [[ "${verbose_message_upper}" != *"ERROR"* ]]; then
            verbose_message="ERROR: ${verbose_message}"
        fi
    else
        if [ ${verbose_level} -eq 2 ]; then
            verbose_color=2
            if [ ${verbose_level_prefix} -eq 0 ] &&  [[ "${verbose_message_upper}" != *"NOTICE"* ]]; then
                verbose_message="NOTICE: ${verbose_message}"
            fi
        else
            if [ ${verbose_level} -eq 3 ]; then
                verbose_color=3
                if [ ${verbose_level_prefix} -eq 0 ] &&  [[ "${verbose_message_upper}" != *"WARN"* ]]; then
                    verbose_message="WARNING: ${verbose_message}"
                fi
            else
                if [ ${verbose_level} -eq 4 ]; then
                    verbose_color=4
                    if [ ${verbose_level_prefix} -eq 0 ] &&  [[ "${verbose_message_upper}" != *"INFO"* ]]; then
                        verbose_message="INFO: ${verbose_message}"
                    fi
                else
                    if [ ${verbose_level} -eq 5 ]; then
                        verbose_color=5
                    else
                        if [ ${verbose_level} -eq 6 ]; then
                            verbose_color=6
                        else
                            if [ ${verbose_level} -eq 7 ]; then
                                verbose_color=7
                            else
                                if [ ${verbose_level} -eq 8 ]; then
                                    verbose_color=8
                                    if [ ${verbose_level_prefix} -eq 0 ] &&  [[ "${verbose_message_upper}" != *"DEBUG"* ]]; then
                                        verbose_message="DEBUG: ${verbose_message}"
                                    fi
                                else
                                    verbose_color=9
                                    if [ ${verbose_level_prefix} -eq 0 ] &&  [[ "${verbose_message_upper}" != *"DEBUG"* ]]; then
                                        verbose_message="XDEBUG: ${verbose_message}"
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    if [ ${verbosity} -ge ${verbose_level} ]; then

        if [ ${BASH_VERSINFO} -ge 4 ]; then
            verbose_message_upper="${verbose_message^^}"
        else
            verbose_message_upper=$(echo "${verbose_message}" | tr '[:lower:]' '[:upper:]')
        fi

        local -i verbose_pad_left verbose_pad_right

        if [[ ${Verbose_Pad_Left} =~ ^[0-9]+$ ]]; then
            verbose_pad_left=${Verbose_Pad_Left}
        fi

        if [[ ${Verbose_Pad_Right} =~ ^[0-9]+$ ]]; then
            verbose_pad_right=${Verbose_Pad_Right}
        fi

        local v1 v2

        if [[ "${verbose_message_upper}" == *":"* ]]; then
            v1="${verbose_message%%:*}"
            v1="${v1#"${v1%%[![:space:]]*}"}"
            v1="${v1%"${v1##*[![:space:]]}"}"
            v2="${verbose_message#*:}"
            v2="${v2#"${v2%%[![:space:]]*}"}"
            v2="${v2%"${v2##*[![:space:]]}"}"
            printf -v verbose_message "%-${verbose_pad_left}b : %b" "${v1}" "${v2}"
            unset v1 v2
        fi

        if [[ "${verbose_message_upper}" == *"="* ]]; then
            v1="${verbose_message%%=*}"
            v1="${v1#"${v1%%[![:space:]]*}"}"
            v1="${v1%"${v1##*[![:space:]]}"}"
            v2="${verbose_message#*=}"
            v2="${v2#"${v2%%[![:space:]]*}"}"
            v2="${v2%"${v2##*[![:space:]]}"}"
            printf -v verbose_message "%-${verbose_pad_right}b = %b" "${v1}" "${v2}"
            unset v1 v2
        fi

        if [ ${#TPUT_SGR0} -gt 0 ]; then
            if [ ${#verbose_color} -eq 0 ]; then
                verbose_color=${verbose_level}
            fi
            if [ ${verbose_color} -gt 8 ]; then
                verbose_color=8
            fi
            local tput_set_af_v="TPUT_SETAF_${verbose_color}"
            if [ ${verbose_level} -le 7 ] && [ ${#TPUT_BOLD} -gt 0 ]; then
                verbose_message="${TPUT_BOLD}${!tput_set_af_v}${verbose_message}${TPUT_SGR0}"
            else
                verbose_message="${!tput_set_af_v}${verbose_message}${TPUT_SGR0}"
            fi
            unset -v tput_set_af_v
        fi

        (>&2 printf "%b\n" "${verbose_message}")

    fi

    unset -v verbose_level verbosity
}

export -f verbose