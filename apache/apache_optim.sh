#!/bin/bash
echo "Calcul pour le paramètre MaxClients/MaxRequestWorkers pour apache2"
APACHE="apache2"
APACHEMEM=$(ps -aylC $APACHE |grep "$APACHE" |awk '{print $8'} |sort -n |tail -n 1)
APACHEMEM=$(expr $APACHEMEM / 1024)
SQLMEM=$(ps -aylC mysqld |grep "mysqld" |awk '{print $8'} |sort -n |tail -n 1)
SQLMEM=$(expr $SQLMEM / 1024)
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
   echo "Stop apache2"
   /etc/init.d/$APACHE stop &> /dev/null
   TOTALFREEMEM=$(free -m |head -n 2 |tail -n 1 |awk '{free=($4); print free}')
   TOTALMEM=$(free -m |head -n 2 |tail -n 1 |awk '{total=($2); print total}')
   SWAP=$(free -m |head -n 4 |tail -n 1 |awk '{swap=($3); print swap}')
   MAXCLIENTS=$(expr $TOTALFREEMEM / $APACHEMEM)
   MINSPARESERVERS=$(expr $MAXCLIENTS / 4)
   MAXSPARESERVERS=$(expr $MAXCLIENTS / 2)
   echo "Start apache2"
   /etc/init.d/$APACHE start &> /dev/null
   /usr/sbin/a2query -M | grep prefork
   if [ $? -ne 1 ]
   then 
	echo "Mémoire totale $TOTALMEM"
	echo "Mémoire libre $TOTALFREEMEM"
	echo "Swap : $SWAP"
	echo "Processus apache le plus élevé $APACHEMEM"
	echo "Mémoire occupée par MYSQL $SQLMEM"
	echo "Mémoire libre totale : $TOTALFREEMEM"
	echo " ================================== "
	echo "	MaxRequestWorkers		$MAXCLIENTS"
	echo "	MinSpareThreads		 $MINSPARESERVERS"
	echo "	MaxSpareThreads		 $MAXSPARESERVERS"
	echo "	MaxRequestsPerChild		1000"
	echo " ================================== "
	echo "nano /etc/apache2/mods-enabled/prefork.conf"
else
	echo "Mémoire totale $TOTALMEM"
	echo "Mémoire libre $TOTALFREEMEM"
	echo "Swap : $SWAP"
	echo "Processus apache le plus élevé $APACHEMEM"
	echo "Mémoire occupée par MYSQL $SQLMEM"
	echo "Mémoire libre totale : $TOTALFREEMEM"
	echo " ================================== "
	echo "	MaxRequestWorkers		$MAXCLIENTS"
	echo "	MinSpareThreads		 $MINSPARESERVERS"
	echo "	MaxSpareThreads		 $MAXSPARESERVERS"
	echo "	MaxRequestsPerChild		1000"
	echo " ================================== "
	echo "nano /etc/apache2/mods-enabled/worker.conf"
fi 
fi
