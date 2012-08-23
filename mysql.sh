#!/bin/bash

set -e

. settings

echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASS" > /tmp/mysql.preseed
echo "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PASS" >> /tmp/mysql.preseed
cat /tmp/mysql.preseed | debconf-set-selections
rm /tmp/mysql.preseed

#apt-get update
#apt-get upgrade

# mysql
apt-get install -y python-mysqldb mysql-server
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
service mysql restart
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASS}' WITH GRANT OPTION; FLUSH PRIVILEGES;" \
      | mysql -u root -p$MYSQL_ROOT_PASS

echo "mysql install over!"
sleep 1
