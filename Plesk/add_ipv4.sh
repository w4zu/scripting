#!/bin/bash
#Usage bash add_ipv4.sh ip mask interface
#exemple : bash add_ipv4.sh 10.0.0.1 255.255.255.255 ens10
ipv4=$1
mask=$2
interface=$3

plesk bin ipmanage --create $ipv4 -type exclusive -mask $mask -interface $interface
