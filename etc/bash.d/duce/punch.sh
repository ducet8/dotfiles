# vim: ft=sh
# 2023.07.26 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

punch() {
    if [ ! "${1}" ]; then
	echo "punch must be run with an argument to be used as the note"
	return 1
    fi

    if [[ "$(tail -1 ${HOME}/.timecard | awk '{print $2}')" != "$(date '+%A')" ]] && [[ ! -z "$(tail -1 ${HOME}/.timecard)" ]]; then
	if [ "$(date '+%A')" == 'Monday' ]; then
	    echo "####" >>${HOME}/.timecard
	fi
	echo >>${HOME}/.timecard
    fi

    if [ "${1}" == 'doh' ]; then
	sed -i '$d' ${HOME}/.timecard
	if [[ -z "$(tail -1 ${HOME}/.timecard)" ]]; then
	    sed -i '$d' ${HOME}/.timecard
	fi
    elif [ "${1}" == 'in' ]; then
        echo "[$(date '+%Y-%m-%d %A %H:%M:%S')] - punch in" >>${HOME}/.timecard
    elif [ "${1}" == 'out' ]; then
        echo "[$(date '+%Y-%m-%d %A %H:%M:%S')] - punch out" >>${HOME}/.timecard
    else
        echo "[$(date '+%Y-%m-%d %A %H:%M:%S')] - ${*}" >>${HOME}/.timecard
    fi
    echo
}
