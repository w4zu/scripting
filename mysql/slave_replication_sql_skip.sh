#!/bin/bash
declare -i cpt=0

declare -i cpttemp=0

maxcpt=10



while [ $cpttemp -lt $maxcpt ] ;do

until mysql -e "show slave status\G;" | grep -i "Slave_SQL_Running: Yes";do
  mysql -e "stop slave; SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1; start slave;";
#  sleep 2;
echo $cpt

cpt=$cpt+1

cpttemp=0

done

sleep 1;

cpttemp=$cpttemp+1

done

echo "SQL Slave OK"
