#!/bin/bash 
memory=$(free | grep -v -i swap |awk 'FNR == 2 {print $4}' |awk '{ byte = $1 /1024/1024 ; byte =$1 /1024/2 ; print byte}' |cut -d "." -f1)
ncores=$(cat /proc/cpuinfo |grep processor |grep -v name |wc -l)

pm_max_children=$(echo $(($memory/10)))
pm_start_servers=$(echo $(($ncores*4)))
pm_min_spare_servers=$(echo $(($ncores*2)))
pm_max_spare_servers=$(echo $(($ncores*4)))
pm_max_requests="1000"

echo '"pm_min_spare_servers": "'$pm_min_spare_servers'"'
echo '"pm_max_spare_servers": "'$pm_max_spare_servers'"'
echo '"pm_max_children": "'$pm_max_children'"'
echo '"pm_start_servers": "'$pm_start_servers'"'
echo '"pm_max_requests": "'$pm_max_requests'"'
