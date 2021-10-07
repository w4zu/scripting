#!/bin/bash
#Check load average 15mins
SCRIPTNAME=`basename $0`

export LOCKSYNC="$dirlock/$SCRIPTNAME.lock"
PID=$$
echo "["$(date +"%Y/%m/%d %H:%M:%S")"] Trying to launch script $0"
if [ -f "$LOCKSYNC" ]
then
        echo "Wait: lockfile "$LOCKSYNC" is present. we must verify..."
        PIDLOCK=`cat $LOCKSYNC`
        if [ -f /proc/$PIDLOCK/exe ]
        then
                echo "The process is currently running. Launching $SCRIPTNAME aborted."
                exit
        else
                echo "The process isn't currently running anymore. Launching $SCRIPTNAME..."
                rm $LOCKSYNC
        fi
fi
echo "Lockingfile creation... "$LOCKSYNC
echo $PID > $LOCKSYNC

date=$(date)
log="/root/memoryclean.log"
load5=$(uptime |grep load | cut -d " " -f 15 | cut -d "." -f 1)
load1=$(uptime |grep load | cut -d " " -f 14 | cut -d "." -f 1)
load15=$(uptime |grep load | cut -d " " -f 16 | cut -d "." -f 1)

function restart()
{
/usr/sbin/apachectl restart
}

check=$load15

if [[ $check -ge 800 ]]
then
    echo "Problem detected"
    restart    
    echo "$date" >> $log
else
    echo "All is OK"
fi

