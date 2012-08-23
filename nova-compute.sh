#!/bin/bash

set -e
. settings

apt-get update
apt-get upgrade

echo "time synchronization..."
ntpdate $CONTROLLER_IP  
hwclock -w
echo "59 8 * * * root /usr/sbin/ntpdate $CONTROLLER_IP;hwclock -w" >>/etc/crontab

apt-get install -y python-mysqldb mysql-client curl
apt-get install -y nova-compute nova-vncproxy 
apt-get install -y novnc

if [ $MULTI_HOST = 'True' ]; then apt-get install -y nova-network;/etc/init.d/networking restart;fi

/etc/init.d/networking restart

# api-paste.ini.tmpl
sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" api-paste.ini.tmpl > api-paste.ini
sed -e "s,%SERVICE_TENANT_NAME%,$SERVICE_TENANT_NAME,g" -i api-paste.ini
sed -e "s,%SERVICE_PASSWORD%,$SERVICE_PASSWORD,g" -i api-paste.ini

# nova.conf.tmpl
sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" nova.conf.tmpl > nova.conf
sed -e "s,%MYSQL_NOVA_PASS%,$MYSQL_NOVA_PASS,g" -i nova.conf
sed -e "s,%CONTROLLER_IP%,$CONTROLLER_IP,g" -i nova.conf
sed -e "s,%CONTROLLER_IP_PUB%,$CONTROLLER_IP,g" -i nova.conf
sed -e "s,%RABBITMQ_IP%,$RABBITMQ_IP,g" -i nova.conf
sed -e "s,%GLANCE_IP%,$GLANCE_IP,g" -i nova.conf
sed -e "s,%FIXED_RANGE%,$FIXED_RANGE,g" -i nova.conf
sed -e "s,%COMPUTE_IP%,$COMPUTE_IP,g" -i nova.conf
sed -e "s,%MULTI_HOST%,$MULTI_HOST,g" -i nova.conf

if [ $MULTI_HOST = 'False' ]; then
    sed -e "s,%NETWORK_HOST%,$CONTROLLER_IP,g" -i nova.conf
else
    sed -e "s,%NETWORK_HOST%,$MYPRI_IP,g" -i nova.conf                                                                                        
fi                                                                                                                                            
                                                                                                                                              
if [ $NETWORK_TYPE = 'VLAN' ];then                                                                                                            
    sed -e "s,%NETWORK_TYPE%,nova.network.manager.VlanManager,g" -i nova.conf                                                                 
elif [ $NETWORK_TYPE = 'FLATDHCP' ];then                                                                                                      
    sed -e "s,%NETWORK_TYPE%,nova.network.manager.FlatDHCPManager,g" -i nova.conf                                                             
else                                                                                                                                          
    echo "ERROR:network type is not expecting"; exit -1;                                                                                      
fi                                                     

cp nova.conf api-paste.ini /etc/nova/
chown nova:nova /etc/nova/nova.conf /etc/nova/api-paste.ini
rm -f nova.conf api-paste.ini

for a in nova-compute novnc; do service "$a" restart; done 
if [ $MULTI_HOST = 'True' ]; then service nova-network restart;fi

echo "================"
for a in nova-compute novnc; do service "$a" status; done 
if [ $MULTI_HOST = 'True' ]; then service nova-network status;fi

echo "nova-compute install over!"
sleep 1
