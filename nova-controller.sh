#!/bin/bash

set -e
#set -x
#set -n
. settings

#apt-get update
#apt-get upgrade

apt-get install -y ntp
sed -i 's/server ntp.ubuntu.com/server ntp.ubuntu.com\nserver 127.127.1.0\nfudge 127.127.1.0 stratum 10/g' /etc/ntp.conf
service ntp restart

apt-get install -y python-mysqldb mysql-client curl
apt-get install -y nova-api nova-scheduler nova-cert nova-consoleauth 
apt-get install -y nova-volume

if [ $MULTI_HOST = 'False' ]; then apt-get install -y nova-network;/etc/init.d/networking restart; fi

mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'DROP DATABASE IF EXISTS nova;'
mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE nova;'
echo "GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY '$MYSQL_NOVA_PASS'; FLUSH PRIVILEGES;" | mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS

# api-paste.ini.tmpl
sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" api-paste.ini.tmpl > api-paste.ini
sed -e "s,%SERVICE_TENANT_NAME%,$SERVICE_TENANT_NAME,g" -i api-paste.ini
sed -e "s,%SERVICE_PASSWORD%,$SERVICE_PASSWORD,g" -i api-paste.ini

# nova.conf.tmpl
sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" nova.conf.tmpl > nova.conf
sed -e "s,%MYSQL_NOVA_PASS%,$MYSQL_NOVA_PASS,g" -i nova.conf
sed -e "s,%CONTROLLER_IP%,$CONTROLLER_IP,g" -i nova.conf
sed -e "s,%CONTROLLER_IP_PUB%,$CONTROLLER_IP_PUB,g" -i nova.conf
sed -e "s,%RABBITMQ_IP%,$RABBITMQ_IP,g" -i nova.conf
sed -e "s,%GLANCE_IP%,$GLANCE_IP,g" -i nova.conf
sed -e "s,%FIXED_RANGE%,$FIXED_RANGE,g" -i nova.conf
sed -e "s,%COMPUTE_IP%,$COMPUTE_IP,g" -i nova.conf
#sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" -i nova.conf
#sed -e "s,%VLAN_INTERFACE%,$VLAN_INTERFACE,g" -i nova.conf
#sed -e "s,%REGION%,$REGION,g" -i nova.conf #sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" -i nova.conf
#sed -e "s,%FIXED_RANGE_MASK%,$FIXED_RANGE_MASK,g" -i nova.conf
#sed -e "s,%FIXED_RANGE_NET%,$FIXED_RANGE_NET,g" -i nova.conf
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
rm -f nova.conf api-paste.ini

chown nova:nova /etc/nova/nova.conf /etc/nova/api-paste.ini

service nova-api restart
nova-manage db sync

for a in nova-api nova-scheduler nova-cert nova-consoleauth; do service "$a" restart; done 
service nova-volume restart
if [ $MULTI_HOST = 'False' ]; then service nova-network restart;fi



#nova-manage network create private $FIXED_RANGE  --num_networks $FIXED_RANGE_NETWORK_COUNT --network_size $FIXED_RANGE_NETWORK_SIZE  --multi_host T --bridge=br100 --bridge_interface eth1 
#nova-manage network create --label vlan1 --fixed_range_v4 10.0.1.0/24 --num_networks 1 --network_size 256 --vlan 1

#create network
#echo ${VLAN_ARRAYS[@]}; echo ${#VLAN_ARRAYS[@]}; echo ${#VLANID_ARRAYS[@]}
if [ $NETWORK_TYPE = "VLAN" ] 
then
    if [ ${#VLAN_ARRAYS[@]} != ${#VLANID_ARRAYS[@]} ]; then echo "ERROR:The arrays of VLAN and VLANID!"; exit -1; fi
    #for i in "${VLAN_ARRAY[@]}"; do echo $i | cut -d . -f 3; done
    for (( i=0,j=0; i<${#VLAN_ARRAYS[@]} && j<${#VLANID_ARRAYS[@]} ;i++,j++ )); do
        #lable='vlan'${VLANID_ARRAYS[$i]};  vlanid=${VLANID_ARRAYS[$j]}; echo $lable $vlanid
	nova-manage network create --label='vlan'${VLANID_ARRAYS[$i]} --fixed_range_v4=${VLAN_ARRAYS[$i]} \
                                   --num_networks=$FIXED_RANGE_NETWORK_COUNT --network_size=$FIXED_RANGE_NETWORK_SIZE --vlan=${VLANID_ARRAYS[$i]} \
                                   --bridge_interface=$BRIDGE_INTERFACE
    done 
elif [ $NETWORK_TYPE = "FLATDHCP" ] 
then
    nova-manage network create --label=private --fixed_range_v4=$FIXED_RANGE  --num_networks=$FIXED_RANGE_NETWORK_COUNT \
                               --network_size=$FIXED_RANGE_NETWORK_SIZE  --multi_host=$MULTI_HOST --bridge=br100 --bridge_interface=$BRIDGE_INTERFACE
else
    echo "ERROR:network type is not expecting"; exit -1;
fi

#nova-manage floating create --ip_range=$FLOATING_RANGE

echo "=============" 
for a in nova-api nova-scheduler nova-cert nova-consoleauth; do service "$a" status; done 
if [ $MULTI_HOST = 'False' ]; then service nova-network status;fi
service nova-volume status

echo "nova-controller install over!"
sleep 1
