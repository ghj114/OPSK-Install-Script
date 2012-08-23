#!/bin/bash

# Import Settings
. settings

if [ ! -f $1'vmlinuz-2.6.32-220.el6.x86_64' ]; then echo 'can not find '$1'vmlinuz-2.6.32-220.el6.x86_64'; exit 1;fi
if [ ! -f $1'initramfs-2.6.32-220.el6.x86_64.img' ] ; then echo 'can not find'$1'initramfs-2.6.32-220.el6.x86_64.img'; exit 1; fi

#exit 0
#TOKEN=`./obtain-token.sh`

export OS_TENANT_NAME=$SERVICE_TENANT_NAME
export OS_USERNAME=glance
export OS_PASSWORD=$SERVICE_PASSWORD
export OS_AUTH_URL='http://'$KEYSTONE_IP':5000/v2.0/'
export OS_REGION_NAME=RegionOne

export | grep OS_
#glance index

echo "Uploading kernel"
RVAL=`glance add name="CentOS6.2-64-Kernel" is_public=true container_format=aki disk_format=aki < $1'vmlinuz-2.6.32-220.el6.x86_64'`
KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`

echo "Uploading ramdisk"
RVAL=`glance add name="CentOS6.2-64-Ramdisk" is_public=true container_format=ari disk_format=ari < $1'initramfs-2.6.32-220.el6.x86_64.img'`
RAMDISK_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`

echo "Uploading image"
glance add name="CentOS6.2-64" is_public=true container_format=ami disk_format=ami kernel_id=$KERNEL_ID ramdisk_id=$RAMDISK_ID < $1'CentOS6.2-64.ext4.img'
