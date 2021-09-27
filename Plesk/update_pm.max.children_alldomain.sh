#!/bin/bash
echo -e "Please define a value for pm.max_children: "
read max_ch

#Checking if max_ch is a number, and asking for defining max_children again if it's not
until [ $max_ch -eq $max_ch 2> /dev/null ]; do
    echo -e "Not a number is entered, please define a value for pm.max_children again: "
    read max_ch
done

# Dumping psa before doing changes:
plesk db dump > /var/lib/psa/dumps/psa.`date +%F`

#Create a temporary file to keep our records:
list=$(mktemp /tmp/tmp.XXXXXXXXX)

#Fetch virtual hosts location and assign it to variable
VHOSTS=$(cat /etc/psa/psa.conf | grep vhost | awk '{print $2}')

# Getting a list of domains working on PHP-FPM handler:
MYSQL_PWD=`cat /etc/psa/.psa.shadow` mysql -uadmin psa -sNe "SELECT domains.name FROM hosting, domains WHERE domains.id=hosting.dom_id AND hosting.php_handler_id LIKE '%fpm%' AND domains.htype='vrt_hst'" > $list

# Create configuration files for all domains:
while read site
do
file="$VHOSTS/system/$site/conf/php.ini"
if [ -f "$file" ]
then
        echo "$file already exists, domain $site skipped."
else
        echo -e "[php-fpm-pool-settings]\npm.max_children = $max_ch\n" > $VHOSTS/system/$site/conf/php.ini
        echo "Domain $site updated"
fi
done  < $list

#Update settings
/usr/local/psa/bin/php_settings -u

#Delete the temporary file
rm $list
