# 2023.07.21 - ducet8@outlook.com

function punch() {
    if [ ! "${1}" ]; then
	echo "punch must be run with an argument to be used as the note"
	return 1
    fi

    # TODO: Add 'doh' parameter to remove last entry
    if [ "${1}" == 'in' ]; then
        echo "[$(date '+%Y-%m-%d %A %H:%M:%S')] - punch in" >>${HOME}/.timecard
    elif [ "${1}" == 'out' ]; then
        echo "[$(date '+%Y-%m-%d %A %H:%M:%S')] - punch out" >>${HOME}/.timecard
    else
        echo "[$(date '+%Y-%m-%d %A %H:%M:%S')] - ${*}" >>${HOME}/.timecard
    fi
    echo
}
