#!/bin/bash

# Settings
. settings

#apt-get update
#apt-get upgrade
apt-get install -y python-mysqldb mysql-client curl
apt-get install -y glance
rm /var/lib/glance/glance.sqlite

# Glance Setup
mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'DROP DATABASE IF EXISTS glance;'
mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE glance;'
echo "GRANT ALL ON glance.* TO 'glance'@'%' IDENTIFIED BY '$MYSQL_GLANCE_PASS'; FLUSH PRIVILEGES;" | mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS

sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" glance-api-paste.ini.tmpl > glance-api-paste.ini
sed -e "s,%SERVICE_TENANT_NAME%,$SERVICE_TENANT_NAME,g" -i glance-api-paste.ini
sed -e "s,%SERVICE_PASSWORD%,$SERVICE_PASSWORD,g" -i glance-api-paste.ini

sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" glance-registry-paste.ini.tmpl > glance-registry-paste.ini
sed -e "s,%SERVICE_TENANT_NAME%,$SERVICE_TENANT_NAME,g" -i glance-registry-paste.ini
sed -e "s,%SERVICE_PASSWORD%,$SERVICE_PASSWORD,g" -i glance-registry-paste.ini

sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" glance-registry.conf.tmpl > glance-registry.conf
sed -e "s,%MYSQL_GLANCE_PASS%,$MYSQL_GLANCE_PASS,g" -i glance-registry.conf
#sed -e "s,%SERVICE_TOKEN%,$SERVICE_TOKEN,g" glance-registry.conf.tmpl > glance-registry.conf
#sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" -i glance-registry.conf
#sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" -i glance-registry.conf

#sed -e "s,%SERVICE_TOKEN%,$SERVICE_TOKEN,g" glance-api.conf.tmpl > glance-api.conf
#sed -e "s,%RABBITMQ_IP%,$RABBITMQ_IP,g" -i glance-api.conf
#sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" -i glance-api.conf

cp glance-api.conf.tmpl /etc/glance/glance-api.conf
cp glance-api-paste.ini glance-registry-paste.ini glance-registry.conf /etc/glance/
rm -f glance-api-paste.ini glance-registry-paste.ini glance-registry.conf 

chown glance:glance /etc/glance/glance-api-paste.ini
chown glance:glance /etc/glance/glance-registry-paste.ini
chown glance:glance /etc/glance/glance-api.conf
chown glance:glance /etc/glance/glance-registry.conf

service glance-api restart
service glance-registry restart

glance-manage version_control 0
glance-manage db_sync

service glance-api restart
service glance-registry restart

#./glance-upload-ttylinux.sh
#./glance-upload-oneiric.sh
#./glance-upload-loader.sh
#./glance-upload-lucid-loader.sh

echo "glance install over!"
sleep 1

