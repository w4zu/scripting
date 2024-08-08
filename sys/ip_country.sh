#!/bin/bash -

if ! type jq &> /dev/null ; then
   echo "You must install jq before use it"
   exit 1
fi

if [ -z $* ] ; then 
   echo "An address is expected as argument"
   exit 1
fi

curl -s https://ip.guide/$1 | jq -r  '. | .network.autonomous_system.country' && sleep 0.1
