#!/bin/bash
#usage : bash add_ip_to_resseler.sh xxx.xxx.xx.xx resseleraccount
# work for ipv6 too
ipv4=$1
resseler=$2

plesk bin ip_pool --add $ipv4 -owner $resseler -type exclusive
