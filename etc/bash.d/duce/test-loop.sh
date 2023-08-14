# vim: ft=sh
# Forked from: joseph.tingiris@gmail.com
# 2023.08.14 - ducet8@outlook.com

test_loop() {
    printf -v COMMAND "%b " "$@"
    COUNTER=0
    SEPERATOR='+--------------------------------------+'

    local program=$(echo "${BASH_SOURCE}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')

    if [ "$COMMAND" == '' ] || [ "$COMMAND" == "${program}" ]; then echo "usage: $0 <command> [sleep seconds]"; return 1; fi

    if [ "$2" != '' ]; then declare -i SLEEP="$2"; fi

    if [ "$SLEEP" == '' ] || [ "$SLEEP" == '0' ]; then declare -i SLEEP=3; fi

    while true; do
        let COUNTER=$COUNTER+1

        echo "$COUNTER $SEPERATOR '$COMMAND' (sleep $SLEEP) $SEPERATOR $COUNTER"
        echo

        eval $COMMAND

        echo
        echo "$COUNTER $SEPERATOR '$COMMAND' (sleep $SLEEP) $SEPERATOR $COUNTER"

        sleep $SLEEP
    done
}
