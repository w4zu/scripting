#!/bin/bash
# Installation nextcloud 18 / Hub with talk/onlyoffice/agenda/task and sharing.
# Require Linux Apache mysql PHP7.4+ minimum/Mariadb/certbot
# Usage : changes variables and chmod +x nextcloud.sh && ./nextcloud.sh
# Your domain must point to the server
# require root 
# Variables can be changed
phpversion=8.0
ncversion=22
domain="cloud.yourdomain.org" # Domain used for the nextcloud application, it must point to the server.
admin_mail="youremail@domain.org" # Your email used for SSL certificates and postmaster for vhost apache.
username=www-data # This is the user who has to launch the application with PHP 
by default is www-data.
mydocroot="/var/www/$username/" # This is where nextcloud is installed.
myvhost="/etc/apache2/sites-enabled/nextcloud_$domain.conf" # Its apache2 file configuration by default.
hostsql="localhost" # IP of your mysql server
# DO NOT CHANGE THIS VARIABLES
userdb="$(openssl rand -hex 12)" #Random userdb
mdpdb="$(openssl rand -hex 18)" #Random password
admin="Admin_$(openssl rand -hex 5)" # Random admin user
adminpw="$(openssl rand -hex 18)" # Random admin password
database=nCn3xtcl0ud # Name of database.
sqlbin="$(which mysql)"
croncertbot=/etc/cron.d/certbot
#Precheck
which php$phpversion
if [ $? -eq 1 ]
then
    echo "php $phpversion installed ? sure ? "
    exit 1
else 
    /usr/bin/php$phpversion -i |grep "PHP Version"
fi
which mysql
then
    echo "mysql or mariadb is not installed ?? "
    exit 2
else 
    /usr/bin/mysql --version
fi
/usr/bin/which certbot/usr/sbin/a2enmod
if [ $? -eq 1 ]
then
    echo "cerbot not installed, for install : sudo apt-get install certbot python-certbot-apache"
    exit 3
fi
if [[ "$username" == www-data ]]
then
   socket="www"
else 
   socket="$username"
fi
#### PRE check OK
#POST Install
apt-get -y --force-yes install redis-server php$phpversion-ldap php-smbclient php$phpversion-gmp php$phpversion-bz2 php-imagick php-apcu php-redis
/usr/sbin/a2enmod http2
/etc/init.d/php$phpversion-fpm restart
/etc/init.d/apache2 restart
#Enable opcache CLI
echo "opcache.enable_cli=1" >> /etc/php/$phpversion/fpm/php.ini
#create Vhost
/usr/bin/touch $myvhost
cat << EOF > $myvhost
<VirtualHost *:80>

    ServerAdmin $admin_mail
    ServerName $domain
    CustomLog /var/log/apache2/$domain_nc_access.log combined
    ErrorLog /var/log/apache2/$domain_nc_error.log
    LogLevel warn

    # You can modify the php socket here
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/$phpversion-$socket.sock|fcgi://localhost"
    </FilesMatch>

    DocumentRoot $mydocroot/nextcloud

    <Directory "$mydocroot/nextcloud">
        Options FollowSymLinks MultiViews
        AllowOverride All
        Order deny,allow
        deny from all
        allow from all
    </Directory>

    <Directory "$mydocroot/nextcloud/.well-known">
        Options FollowSymLinks MultiViews
        AllowOverride All
        Order deny,allow
        deny from all
        allow from all
    </Directory>

</VirtualHost>
<VirtualHost *:443>

    ServerAdmin $admin_mail
    ServerName $domain
    CustomLog /var/log/apache2/$domain_nc_access_ssl.log combined
    ErrorLog /var/log/apache2/$domain_nc_error_ssl.log
    LogLevel warn
    Protocols h2 http/1.1
  
    Header always set Strict-Transport-Security "max-age=15768000; preload"

    # You can modify the php socket here
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/$phpversion-$socket.sock|fcgi://localhost"
    </FilesMatch>


     DocumentRoot $mydocroot/nextcloud

    <Directory "$mydocroot/nextcloud">
        Options FollowSymLinks MultiViews
        AllowOverride All
        Order deny,allow
        deny from all
        allow from all
    </Directory>

    <Directory "$mydocroot/nextcloud/.well-known">
        Options FollowSymLinks MultiViews
        AllowOverride All
        Order deny,allow
        deny from all
        allow from all
    </Directory>

    ServerSignature Off

</VirtualHost>
EOF
/etc/init.d/apache2 restart
/etc/init.d/php$phpversion-fpm restart
#CreateDatabase
$sqlbin -e "CREATE DATABASE ${database};"
$sqlbin -e "GRANT ALL PRIVILEGES ON \`${database}\`.* TO $userdb @'localhost'  IDENTIFIED BY '$mdpdb'"
$sqlbin -e "GRANT ALL PRIVILEGES ON \`${database}\`.* TO $userdb @'$hostsql'  IDENTIFIED BY '$mdpdb'"
$sqlbin -e "FLUSH PRIVILEGES;"
#Test user create
$sqlbin -u${userdb} -p${mdpdb} -h${hostsql} -e "show databases;"
if [ $? -ne 0 ]
then
	echo "Error during the creation of the database, please check if the SQL service is started."
	exit 4
else
#mkdir 
/bin/mkdir -p $mydocroot
#Download Nextcloud
wget https://download.nextcloud.com/server/releases/latest-$ncversion.zip
#Unzip
unzip latest-$ncversion.zip -d $mydocroot
/bin/chown -R $username. $mydocroot
cd $mydocroot
cd nextcloud
#Nextcloud Install
sudo -u $username php occ maintenance:install --database "mysql" --database-name "$database"  --database-user "$userdb" --database-pass "$mdpdb" --admin-user "$admin" --admin-pass "$adminpw"
sudo -u $username php occ config:system:set trusted_domains 1 --value=$domain
sudo -u $username php occ config:system:set memcache.local --value="\OC\Memcache\APCu" --type=string
sudo -u $username php occ config:system:set memcache.locking --value "\OC\Memcache\Redis" --type=string
sudo -u $username php occ config:system:set logtimezone --value="Europe/Paris" --type=string
sudo -u $username php occ config:system:set log_type --value="file"
sudo -u $username php occ config:system:set logfile --value="/var/log/apache2/nextcloud.log"
sudo -u $username php occ config:system:set overwrite.cli.url --value=https://$domain
sudo -u $username php occ config:system:set htaccess.RewriteBase --value='/'
sudo -u $username php occ config:system:set trashbin_retention_obligation --value="auto, 7" --type=string
sudo -u $username php occ config:app:set core backgroundjobs_mode --value="cron"
sudo -u $username php occ config:app:set files default_quota --value="10 GB"
sudo -u $username php occ app:enable admin_audit
sudo -u $username php occ app:enable documentserver_community
sudo -u $username php occ app:enable files_pdfviewer
sudo -u $username php occ app:enable mail
sudo -u $username php occ app:enable contacts
sudo -u $username php occ app:enable calendar
sudo -u $username php occ app:enable deck
sudo -u $username php occ app:enable admin_audit
sudo -u $username php occ app:enable files_trashbin
sudo -u $username php occ app:enable password_policy
sudo -u $username php occ app:enable sharebymail
sudo -u $username php occ app:enable files_accesscontrol
sudo -u $username php occ app:enable onlyoffice
sudo -u $username php occ app:enable spreed
sudo -u $username php occ config:app:set password_policy enforceNumericCharacters --value="1"
sudo -u $username php occ config:app:set password_policy enforceSpecialCharacters --value="1"
sudo -u $username php occ config:app:set password_policy enforceUpperLowerCase --value="1"
sudo -u $username php occ config:app:set password_policy minLength --value="8"
sudo -u $username php occ config:app:set core shareapi_enforce_links_password --value="yes"
sudo -u $username php occ config:app:set sharebymail enforcePasswordProtection --value="yes"
sudo -u $username php occ config:app:set core shareapi_default_expire_date --value="yes"
sudo -u $username php occ config:app:set core shareapi_expire_after_n_days --value="14"
sudo -u $username php occ config:app:set core shareapi_allow_public_upload --value="no"
sudo -u $username php occ config:app:set files_sharing incoming_server2server_share_enabled --value="no"
sudo -u $username php occ config:app:set files_sharing outgoing_server2server_share_enabled --value="no"
sudo -u $username php occ config:app:set files_sharing lookupServerUploadEnabled --value="no"
sudo -u $username php occ config:system:set log_rotate_size --value="10485760" --type=integer
sudo -u $username php occ config:system:set 'auth.bruteforce.protection.enabled' --value="true"
sudo -u $username php occ db:add-missing-indices
sudo -u $username php occ db:convert-filecache-bigint
#add cron
echo "*/15 * * * * /usr/bin/php$phpversion -f /home/$username/htdocs/nextcloud/cron.php" >> /var/spool/cron/crontabs/$username
/bin/chown $username:crontab /var/spool/cron/crontabs/$username
sudo -u $username php -f /$mydocroot/nextcloud/cron.php
#Create SSL certificat with certbot
/usr/bin/certbot --agree-tos --redirect --no-eff-email -m $admin_mail -d $domain
#add crontab for certbot
if [ -f "$croncertbot" ]
then 
    echo "crontab OK"
else
    echo "0 0 * * 0  sudo /usr/bin/certbot renew" >> /etc/cron.d/certbot
    /etc/init.d/apache2 restart
    /etc/init.d/php$phpversion-fpm restart
fi
	echo "################################################################"
	echo "Database : $database" 
	echo "User : $userdb"
	echo "Password : $mdpdb"
	echo "Admin user : $admin"
	echo "Admin passwd : $adminpw"
        echo "Check in administration overview comment in nexcloud admin panel"
	echo "################################################################"
	echo "[Nextcloud]" >> /root/nc_p
	echo "User DB : $userdb" >> /root/nc_p
	echo "Password DB : $mdpdb" >> /root/nc_p
	echo "Admin user : $admin" >> /root/nc_p
	echo "Admin passwd : $adminpw" >> /root/nc_p
	echo "Look file /root/nc_p for db info and admin info
fi
