# Forked from: joseph.tingiris@gmail.com
# 2022.11.09 - ducet8@outlook.com

# replace in files

function rif_usage() {
    echo
    echo "${0} <from> <to>"
    echo
    exit 1
}

function rif() {
    if [ "${1}" == '' ] || [ "${2}" == '' ]; then
        rif_usage
    fi

    REPLACE_FROM="${1}"
    REPLACE_TO="${2}"

    REPLACE_FROM=${REPLACE_FROM//\*/\\\*}
    REPLACE_TO=${REPLACE_TO//\*/\\\*}

    while read FILE; do
        if [ "${FILE}" == "" ]; then continue; fi
        sed -i "/${REPLACE_FROM}/s//${REPLACE_TO}/g" "${FILE}"
        if [ $? -eq 0 ]; then
            echo "Replaced '${REPLACE_FROM}' with '${REPLACE_TO}' in file: ${FILE}"
        else
            echo "FAILED to replace '${REPLACE_FROM}' with '${REPLACE_TO}' in file: ${FILE}"
        fi
    done <<< "$(find . -type f ! -wholename "*.git*" -and ! -wholename "*.svn*" -print0 | xargs -0 -r grep -l "${REPLACE_FROM}")"
}

# export -f rif_usage
# export -f rif