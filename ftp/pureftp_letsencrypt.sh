#!/bin/bash
#Generation certificat let's encrypt pour pureftpd.
#Usage : bash pureftp_letsencrypt.sh domain.org youremail.com
mydocroot="/var/www/"
domaine="$1"
admin_mail="$2"
#Check domaine
if [ -z "$domaine" ]
then 
echo "Please use  : bash pureftp_letsencrypt.sh domain.org youremail.com"
exit 1
else
echo "ok"
fi
if [ -z "$admin_mail" ]
then 
echo "Please use  : bash pureftp_letsencrypt.sh domain.org youremail.com"
exit 2
else
echo "ok"
fi
/usr/local/bin/certbot-auto certonly --agree-tos -m=$admin_mail --webroot -w $mydocroot --domains $domaine 
/bin/mv /etc/ssl/private/pure-ftpd.pem /etc/ssl/private/pure-ftpd.bak
/bin/cat /etc/letsencrypt/live/$domaine/privkey.pem /etc/letsencrypt/live/$domaine/fullchain.pem > /etc/ssl/private/pure-ftpd.pem
/etc/init.d/pure-ftpd restart


