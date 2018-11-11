#!/bin/bash

DIR="$(cd `dirname $0`; pwd)"
BEGIN=`date "+%Y.%m.%d-%H:%M:%S"`
DOTNET_PATH=".dotnet"

export PATH=$PATH:$DIR/$DOTNET_PATH

install() {
    curl https://raw.githubusercontent.com/iDECenter/iInstallScript/master/install.sh > install.sh
    chmod +x install.sh
    ./install.sh
}

run() {
    if [[ -d iDECenter ]]; then
        cd iDECenter
        npm start
        echo "server exited with code $?"
        mkdir ../logs/ > /dev/null 2>&1
        mv logall.log ../logs/log_$BEGIN.log

        exit 0
    else
        echo "iDECenter not installed!!!"
        exit 1
    fi
}

viconf() {
    VI=vim
    command -v vim --version > /dev/null 2>&1 || VI=vi
    $VI iDECenter/config.json
}

dbbackup() {
    cp iDECenter/db.sqlite3 db.sqlite3.$BEGIN
}

makeDaemon() {
    dotnet build iDECenter/iDaemonCenter/iDaemonCenter/iDaemonCenter.csproj -o ../.. -c Release
}

upgradeSelf() {
    curl https://raw.githubusercontent.com/iDECenter/iInstallScript/master/idec.sh > $0
    chmod +x $0
}

upgrade() {
    cd iDECenter
    git pull
    cd iDaemonCenter
    git pull
    cd ../..
    makeDaemon
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
    echo "$0 viconf"
    echo "    edit iDECenter configuration file"
    echo
    echo "$0 dbbackup"
    echo "    backup the database"
    echo
    echo "$0 upgradeself"
    echo "   upgrade this script itself"
    echo
    echo "$0 upgrade"
    echo "    upgrade the project"
    echo
    echo "$0 [help|usage]"
    echo "    display usage"
}

unknownCommand() {
    echo "unknown command: $1"
    exit 1
}

cd $DIR
case "$1" in
    "install") install;;
    "run") run;;
    "viconf") viconf;;
    "dbbackup") dbbackup;;
    "upgrade") upgrade;;
    "help") ;&
    "usage") ;&
    "") dispUsage;;
    *) unknownCommand $1;;
esac
