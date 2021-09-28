#!/bin/bash
# exemple : bash createmail.sh filewithmail.txt
# in filewithmail.txt  : mail@domain.org strongpassword
file=$1
while IFS= read -r line
do
     email=`echo $line | awk '{print $1}'`
     pswd=`echo $line | awk '{print $2}'`
     plesk bin mail -c $email -passwd $pswd -mailbox true -mbox_quota 20M -antivirus inout
     sleep 1 
done <"$file"
