#!/usr/bin/env bash
# Forked from: joseph.tingiris@gmail.com
# 2022.08.04 - ducet8@outlook.com

function test-loop() {
    printf -v COMMAND "%b " "$@"
    COUNTER=0
    SEPERATOR="+--------------------------------------+"

    if [ "$COMMAND" == "" ] || [ "$COMMAND" == "$0" ]; then echo "usage: $0 <command> [sleep seconds]"; exit 1; fi

    if [ "$2" != "" ]; then declare -i SLEEP="$2"; fi

    if [ "$SLEEP" == "" ] || [ "$SLEEP" == "0" ]; then declare -i SLEEP=3; fi

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

export -f test-loop