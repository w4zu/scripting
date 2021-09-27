#!/bin/bash -n

tmp_directory=/tmp/aa
ipset_name=dn-blocklist
DATE=$(date +%Y%m%d)

/sbin/iptables-save > ${tmp_directory}/IPTABLEOK-$DATE

ipset -N $ipset_name hash:net
iptables -I INPUT -p tcp -m set --match-set $ipset_name src -j DROP
rm ${tmp_directory}/*.zone 2> /dev/null

for country in cn ro ua ru sa ; do
    wget -P ${tmp_directory}/ http://www.ipdeny.com/ipblocks/data/countries/$country.zone
done
# Add each IP address from the downloaded list into the ipset 'china'
for file in ${tmp_directory}/*.zone ; do
    while read line ; do
        ipset -A $ipset_name $line ;
     done < $file
done
