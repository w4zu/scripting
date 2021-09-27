#!/bin/sh
# Name of the processus to monitor
pcs="apache2"
# Restart command : example : service bind start, service httpd start, etc.
restart="service $pcs start"
# Time to sleep before recheck
sbc=3
# Function to check if the process is running
check_process() {
    echo "$tstamp : checking $1"
    [ "$1" = "" ]  && return 0
    [ `pgrep -n $1` ] && return 1 || return 0
      }
for i in `seq 1 100`; do
tstamp=`date +%T` #Define timestamp
# Execute checking
echo "$tstamp : checking if the process running..."
check_process $pcs
# If process don't running execute $restart command 
[ $? -eq 0 ] && echo "$ts: not running, restarting..." && `$restart`
sleep $sbc
done
