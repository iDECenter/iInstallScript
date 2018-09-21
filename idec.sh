#!/bin/bash

run() {
    if [[ -d iDECenter ]]; then
        starttime=`date "+%Y.%m.%d-%H:%M:%S"`
        cd iDECenter
        npm start
        echo "server exited with code $?"
        mkdir ../logs/ > /dev/null 2>&1
        mv logall.log ../logs/log_$starttime.log

        exit 0
    else
        echo "iDECenter not installed"
        exit 1
    fi
}

dispUsage() {
    echo "$0"
    echo
    echo "$0 install"
    echo "    install iDECenter"
    echo
    echo "$0 run"
    echo "    run iDECenter"
    echo
    echo "$0 [help|usage]"
    echo "    display usage"
}

unknownCommand() {
    echo "unknown command: $1"
    exit 1
}

case "$1" in
    "run") run;;
    "help") ;&
    "usage") ;&
    "") dispUsage;;
    *) unknownCommand $1;;
esac
