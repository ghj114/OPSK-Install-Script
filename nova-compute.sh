#!/bin/bash

# Settings
. settings

#apt-get update
#apt-get upgrade
echo "time synchronization..."
ntpdate $CONTROLLER_IP  
hwclock -w

apt-get install -y python-mysqldb mysql-client curl
apt-get install -y nova-compute nova-vncproxy 
#apt-get install -y nova-network
apt-get install -y novnc

apt-get install -y bridge-utils
/etc/init.d/networking restart

# Nova Setup
sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" api-paste.ini.tmpl > api-paste.ini
sed -e "s,%SERVICE_TENANT_NAME%,$SERVICE_TENANT_NAME,g" -i api-paste.ini
sed -e "s,%SERVICE_PASSWORD%,$SERVICE_PASSWORD,g" -i api-paste.ini
#sed -e "s,999888777666,$SERVICE_TOKEN,g" api-paste-keystone.ini.tmpl > api-paste-keystone.ini
#sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" -i api-paste-keystone.ini

# Nova Config
sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" nova.conf.tmpl > nova.conf
sed -e "s,%MYSQL_NOVA_PASS%,$MYSQL_NOVA_PASS,g" -i nova.conf
sed -e "s,%CONTROLLER_IP%,$CONTROLLER_IP,g" -i nova.conf
sed -e "s,%RABBITMQ_IP%,$RABBITMQ_IP,g" -i nova.conf
sed -e "s,%GLANCE_IP%,$GLANCE_IP,g" -i nova.conf
sed -e "s,%FIXED_RANGE%,$FIXED_RANGE,g" -i nova.conf
sed -e "s,%COMPUTE_IP%,$COMPUTE_IP,g" -i nova.conf

cp nova.conf api-paste.ini /etc/nova/
chown nova:nova /etc/nova/nova.conf /etc/nova/api-paste.ini
rm -f nova.conf api-paste.ini

for a in nova-compute novnc; do service "$a" restart; done 
#service nova-network restart

echo "================"
for a in nova-compute nova-network novnc; do service "$a" status; done 
echo "nova-compute install over!"
sleep 1
