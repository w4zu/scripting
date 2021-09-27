#!/bin/bash

# Id MySQL
MYSQL_USER="user"
MYSQL_PASSWORD="greatpassword"

DATE=$(date +"%Y%m%d")
TIME=$(date +"%Y%m%d-%H%M%S")

BACKUP_DIR="/home/youruser/mysqlfolder"

# Identifiants MySQL

MYSQL_USER="user"
MYSQL_PASSWORD="greatpassword"

MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

# Bases de données MySQL à ignorer

SKIPDATABASES="Database|information_schema|performance_schema|mysql|sys"

RETENTION=14

mkdir -p $BACKUP_DIR/$DATE

# Retrieve a list of all databases

databases=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -v "($SKIPDATABASES)" `
# Dumb the databases in seperate names and gzip the .sql file

for db in $databases; do
echo $db
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --skip-lock-tables --events --databases $db | gzip > "$BACKUP_DIR/$DATE/$db-$TIME.sql.gz"
done

# Remove files older than X days

find $BACKUP_DIR/* -mtime +$RETENTION -delete
