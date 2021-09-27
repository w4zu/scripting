#!/bin/bash
plesk bin subscription --list > /root/listsub
cd /var/www/vhosts/system/
for i in `cat /root/listsub`;do cat $i/conf/nginx.conf |grep -A4 listen | cut -d " " -f2| sed -e 's/server_name//g'|grep -v ipv6 |grep -v ipv4 | sed -e 's/;//g' | sed -e 's/:80/:443/g' | sed -e 's/\[//g'| sed -e 's/\]:443//g' | sed -e 's/:443//g' | uniq | sort -n | uniq -c | awk '{ print $2}';done > /root/liste.txt
for i in `cat /root/listsub`;do cat $i/conf/nginx_ip_default.conf |grep -A4 listen | cut -d " " -f2| sed -e 's/server_name//g'|grep -v ipv6|grep -v ipv4 | sed -e 's/;//g' | sed -e 's/:80/:443/g' | sed -e 's/\[//g'| sed -e 's/\]:443//g' | sed -e 's/:443//g' | uniq | sort -n | uniq -c | awk '{ print $2}';done  >> /root/liste.txt
sed -i '/^$/d' /root/liste.txt
echo "--" >> /root/liste.txt
cat /root/liste.txt |grep -v "www." > /root/listwowww.txt
echo "Look file /root/listwowww.txt"
