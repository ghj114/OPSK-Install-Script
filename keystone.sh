#!/bin/bash

set -e
. settings

#apt-get update
#apt-get upgrade
apt-get install -y python-mysqldb mysql-client curl
apt-get install -y keystone
rm -f /var/lib/keystone/keystone.db

# Keystone Setup
mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'DROP DATABASE IF EXISTS keystone;'
mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE keystone;'
echo "GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$MYSQL_KEYSTONE_PASS';FLUSH PRIVILEGES;" | mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS

# keystone.conf.tmpl
sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" keystone.conf.tmpl > keystone.conf
sed -e "s,%MYSQL_KEYSTONE_PASS%,$MYSQL_KEYSTONE_PASS,g" -i keystone.conf
sed -e "s,%SERVICE_TOKEN%,$SERVICE_TOKEN,g" -i keystone.conf

cp keystone.conf /etc/keystone/keystone.conf
chown keystone /etc/keystone/keystone.conf
rm -f keystone.conf

service keystone restart
keystone-manage db_sync

chmod +x keystone_data.sh
./keystone_data.sh

echo "keystone install over!"
sleep 1

# Keystone Data
#sed -e "s,%HOST_IP%,$HOST_IP,g" keystone_data.sh.tmpl > keystone_data.sh
#sed -e "s,%SERVICE_TOKEN%,$SERVICE_TOKEN,g" -i keystone_data.sh
#sed -e "s,%ADMIN_PASSWORD%,$ADMIN_PASSWORD,g" -i keystone_data.sh
#sed -e "s,%REGION%,$REGION,g" -i keystone_data.sh
#sed -e "s,%COMPUTE_IP%,$COMPUTE_IP,g" -i keystone_data.sh
#sed -e "s,%GLANCE_IP%,$GLANCE_IP,g" -i keystone_data.sh
#sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" -i keystone_data.sh

