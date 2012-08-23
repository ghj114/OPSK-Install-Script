#!/bin/bash

# Settings
set -e
. settings

apt-get install -y memcached libapache2-mod-wsgi openstack-dashboard

service apache2 restart

echo "dashboard install over!"
sleep 1
#apt-get install -y openstackx
#apt-get install -y libapache2-mod-wsgi
#apt-get install -y openstack-dashboard

# Dashboard Setup

#mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'DROP DATABASE IF EXISTS horizon;'
#mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE horizon;'
#echo "GRANT ALL ON horizon.* TO 'horizon'@'%' IDENTIFIED BY '$MYSQL_HORIZON_PASS'; FLUSH PRIVILEGES;" | mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS

#sed -e "s,999888777666,$SERVICE_TOKEN,g" local_settings.py.tmpl > local_settings.py
#sed -e "s,%MYSQL_HOST%,$MYSQL_HOST,g" -i local_settings.py
#sed -e "s,%MYSQL_HORIZON_PASS%,$MYSQL_HORIZON_PASS,g" -i local_settings.py
#sed -e "s,%KEYSTONE_IP%,$KEYSTONE_IP,g" -i local_settings.py
#
#cp local_settings.py /etc/openstack-dashboard/local_settings.py
#/usr/share/openstack-dashboard/dashboard/manage.py syncdb
