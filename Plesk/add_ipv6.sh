#!/bin/bash
#Usage bash add_ipv4.sh ip mask interface
#exemple : bash add_ipv4 "fe80::xxx:xxxx:xxxx:xxxx 64 ens10
ipv6=$1
mask=$2
interface=$3

plesk bin ipmanage --create $ipv6 -type exclusive -mask $mask -interface $interface
