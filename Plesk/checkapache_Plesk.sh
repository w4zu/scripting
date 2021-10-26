#!/bin/bash
#Check Apache via status page
#curl http://localhost:7079/server-status | grep prefork
curl http://localhost:7080/server-status |grep "Server MPM"
if [ $? -ne 0 ]
then
    service apache2 restart
fi
