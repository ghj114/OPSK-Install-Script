#!/bin/bash

# Settings
. settings

#apt-get update
#apt-get upgrade

apt-get install -y ntp
sed -i 's/server ntp.ubuntu.com/server ntp.ubuntu.com\nserver 127.127.1.0\nfudge 127.127.1.0 stratum 10/g' /etc/ntp.conf
service ntp restart

apt-get install -y python-mysqldb mysql-client curl
apt-get install -y nova-api nova-scheduler nova-cert nova-consoleauth 
#apt-get install -y nova-network
#apt-get install -y nova-api nova-scheduler nova-objectstore nova-vncproxy nova-ajax-console-proxy openstackx python-keystone python-mysqldb mysql-client curl
#apt-get install nova-rootwrap


mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'DROP DATABASE IF EXISTS nova;'
mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE nova;'
echo "GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY '$MYSQL_NOVA_PASS'; FLUSH PRIVILEGES;" | mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS

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
#sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" -i nova.conf
#sed -e "s,%VLAN_INTERFACE%,$VLAN_INTERFACE,g" -i nova.conf
#sed -e "s,%REGION%,$REGION,g" -i nova.conf #sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" -i nova.conf
#sed -e "s,%FIXED_RANGE_MASK%,$FIXED_RANGE_MASK,g" -i nova.conf
#sed -e "s,%FIXED_RANGE_NET%,$FIXED_RANGE_NET,g" -i nova.conf

cp nova.conf api-paste.ini /etc/nova/
rm -f nova.conf api-paste.ini

chown nova:nova /etc/nova/nova.conf /etc/nova/api-paste.ini

service nova-api restart
nova-manage db sync

for a in nova-api nova-scheduler nova-cert nova-consoleauth; do service "$a" restart; done 
#service nova-network restart
#service nova-ajax-console-proxy restart

nova-manage network create private $FIXED_RANGE  --num_networks $FIXED_RANGE_NETWORK_COUNT --network_size $FIXED_RANGE_NETWORK_SIZE  --multi_host T --bridge=br100 --bridge_interface eth1 
#nova-manage network create --multi_host T --network_size $FIXED_RANGE_NETWORK_SIZE --num_networks $FIXED_RANGE_NETWORK_COUNT --bridge_interface $VLAN_INTERFACE --fixed_range_v4 $FIXED_RANGE --label internal
#nova-manage floating create --ip_range=$FLOATING_RANGE

echo "=============" 
for a in nova-api nova-scheduler nova-cert nova-consoleauth; do service "$a" status; done 
echo "nova-controller install over!"
sleep 1
