#!/bin/bash

apt-get autoremove --purge -y python-mysqldb mysql-server

apt-get autoremove --purge -y python-mysqldb mysql-client curl

apt-get autoremove --purge -y keystone

apt-get autoremove --purge -y glance 

apt-get autoremove --purge -y ntp 

apt-get autoremove --purge -y rabbitmq-server

apt-get autoremove --purge -y nova-api nova-scheduler nova-cert nova-consoleauth

apt-get autoremove --purge -y memcached libapache2-mod-wsgi openstack-dashboard

apt-get autoremove --purge -y nova-network

apt-get autoremove --purge -y nova-compute nova-vncproxy

apt-get autoremove --purge -y novnc

apt-get autoremove --purge -y bridge-utils

apt-get autoremove --purge -y nova-volume


rm -fr /var/lib/nova
rm -fr /var/lib/mysql
rm -fr /var/lib/keystone
rm -fr /var/lib/glance
rm -fr /var/log/nova
	
#if [ $# -eq 0 ]; then echo "Usage: ./clean.sh -c -p ..."; exit -1; fi
#while [ $# -gt 0 ]
#do
#	case $1 in
#        -c | controller) controller=true; ;; 
#	-p | compute) compute=true; ;;
#	*) echo "unrecognized:$1"; echo "Usage: ./clean.sh -c -p ..."; exit -1; ;;
#	esac
#	shift
#done
#
## controller
#if [ "$controller" = "true" ]
#then 
#	apt-get autoremove --purge -y python-mysqldb mysql-server
#
#	apt-get autoremove --purge -y python-mysqldb mysql-client curl
#	apt-get autoremove --purge -y keystone
#
#	#apt-get autoremove --purge -y python-mysqldb mysql-client curl
#	apt-get autoremove --purge -y glance 
#
#	apt-get autoremove --purge -y ntp 
#	apt-get autoremove --purge -y rabbitmq-server
#	#apt-get autoremove --purge -y python-mysqldb mysql-client curl
#	apt-get autoremove --purge -y nova-api nova-scheduler nova-cert nova-consoleauth
#
#	#apt-get autoremove --purge -y python-mysqldb mysql-client curl
#	apt-get autoremove --purge -y memcached libapache2-mod-wsgi openstack-dashboard
#	apt-get autoremove --purge -y nova-network
#	
#	rm -fr /var/lib/nova
#	rm -fr /var/lib/mysql
#fi
#
## compute
#if [ "$compute" = "true" ]
#then
#	apt-get autoremove --purge -y python-mysqldb mysql-client curl
#	apt-get autoremove --purge -y nova-compute nova-vncproxy
#	apt-get autoremove --purge -y novnc
#	apt-get autoremove --purge -y bridge-utils
#	apt-get autoremove --purge -y nova-network
#fi
