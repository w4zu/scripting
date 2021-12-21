#!/bin/bash -

nb_show=${1:-30}

echo "top $nb_show of detected ip"
echo "---------------------"
/usr/bin/lynx -dump -width 200 http://127.0.0.1:7080/server-status  | awk '{print$11" "$12" "$13}' | grep -E "([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}" | sort -nk 1  | uniq -c  | sort -g | tail -n $nb_show
echo -e "\n"
echo "top $nb_show of called url"
echo "--------------------"
/usr/bin/lynx -dump -width 200 http://127.0.0.1:7080/server-status | awk '{print$15" "$13}'  | grep -E "^/" | sort -nk 1  | uniq -c  | sort -g | tail -n $nb_show

