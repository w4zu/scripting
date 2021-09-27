#!/bin/bash 
# mpm worker optimizer
# Documentation from https://httpd.apache.org/docs/2.4/fr/mod/event.html
memory=$(free | grep -v -i swap |awk 'FNR == 2 {print $4}' |awk '{ byte = $1 /1024/1024 ; byte =$1 /1024/2 ; print byte}' |cut -d "." -f1)
memorymysql=$(ps aux | grep mysql | awk '{print $6/1024;}' | awk '{avg += ($1 - avg) / NR;} END {print avg;}'|cut -d "." -f1)
memoryapache=$(ps aux | grep apache | awk '{print $6/1024;}' | awk '{avg += ($1 - avg) / NR;} END {print avg;}'|cut -d "." -f1)
ncores=$(cat /proc/cpuinfo |grep processor |grep -v name |wc -l)
memcalc=$(echo $(($memory-$memorymysql)))
memapache=$(echo $(($memcalc-$memoryapache)))
maxrequestworkers=$(echo $(($memcalc/$memoryapache)))
minsparethreads=$(echo $(($maxrequestworkers/2)))
trashingpoint=
if [ $ncores == 2 ] || [ $ncores == 4 ]
then
   threadsperchild=25
fi
if [ $ncores == 8 ]
then
   threadsperchild=32
fi
if [ $ncores == 16 ]
then
   threadsperchild=50
fi

if [ $ncores == 32 ]
then
   threadsperchild=64
fi
serverlimit=$(echo $(($maxrequestworkers/$threadsperchild)))
if [ $serverlimit -le 16 ]
then
   serverlimit=16
fi
maxsparethreads=$(echo $(($minsparethreads+$threadsperchild)))
/usr/sbin/a2query -M |grep event
if [ $? -ne 1 ]
then 
   echo "ServerLimit 	$serverlimit"
   echo "StartServers 	$ncores"
   echo "MinSpareThreads 	$minsparethreads"
   echo "MaxSpareThreads 	$maxsparethreads"
   echo "MaxRequestWorkers		$maxrequestworkers"
   echo "ThreadLimit 	$threadsperchild"
   echo "ThreadsPerChild 	$threadsperchild"
   echo "MaxConnectionsPerChild    1000"
   echo "########################################################"
   echo "# MaxConnectionsPerChild at 1000 prevents memory leaks #"
   echo "# ThreadsPerChild must be no more than Threadlimit     #"
   echo "#                                                      #"
   echo "#                                                      #"
   echo "########################################################"
else
   apachemodused=$(/usr/sbin/a2query -M)
   echo "You don't use mod event."
   echo "Your mod is $apachemodused"
fi
