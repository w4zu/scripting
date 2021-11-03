#!/bin/bash
dpkg -s apache2 > /dev/null
if [ $? -ne 0 ]
then
    "apache not installed"
    exit1
fi
if [ -f /etc/apache2/conf-enabled/security.conf ] && [ -f  /etc/apache2/apache2.conf ]
then
	echo "file security.conf exist"
	sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/apache2/conf-enabled/security.conf
	sed -i 's/ServerSignature On/ServerSignature off/g' /etc/apache2/conf-enabled/security.conf
	sed -i 's/TraceEnable On/TraceEnable Off/g' /etc/apache2/conf-enabled/security.conf
else
    exit 2
fi
/usr/sbin/apache2ctl configtest
if [ $? == 0 ]
then
    service apache2 reload
else
    "problem apache config"
    exit3
fi
