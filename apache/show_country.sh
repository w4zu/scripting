#!/bin/bash
#You can use the script if the ips in your logs are in second position otherwise you have to modify the script according to the position.
# It will display the 10 different countries that make the most connections
# usage : bash show_country.sh access_log
logfile=$1

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

DATE=`date +%Y%m%d`
DATE2=`date +%d/%b/%Y:%H:%M:%S`
DATE3=`date +%d/%b/%Y:%H:%M`
DATE3C="$(echo $DATE3 | sed 's/.$//')"
DATEM5=`date -d '5 minute ago' '+%d/%b/%Y:%H:%M:'`
DATEM4=`date -d '4 minute ago' '+%d/%b/%Y:%H:%M:'`
DATEM3=`date -d '3 minute ago' '+%d/%b/%Y:%H:%M:'`
DATEM2=`date -d '2 minute ago' '+%d/%b/%Y:%H:%M:'`
DATEM1=`date -d '1 minute ago' '+%d/%b/%Y:%H:%M:'`
VALEUR=10

#ADD COUNTRY HERE NOW in COUNTRYBAN.out

DATE3OK=$(echo $DATE3 |head -c-3)
cat $logfile | grep "$DATE3OK" | awk '{ print $2 }'| sort | uniq -c | sort -h |tail -10 |awk '{ print $2 }' > LISTIP.out
for i in `cat LISTIP.out`
do 
curl --silent https://iplist.cc/api/$i |grep -E 'countrycode|"ip":' |sed 's/"countrycode"://g' |sed 's/"ip"://g'|sed 's/"//g' |sed 's/,//g'
done > LISTIPCOUNTRY.out
cat LISTIPCOUNTRY.out | grep -v '[0-9]' |sort| uniq -c| sort -h|tail -n 10
