#!/bin/bash

# Import Settings
. settings

if [ ! -f "ttylinux-uec-amd64-12.1_2.6.35-22_1.tar.gz" ] ; then
	echo "Downloading image"
	wget http://smoser.brickies.net/ubuntu/ttylinux-uec/ttylinux-uec-amd64-12.1_2.6.35-22_1.tar.gz
fi

if [ ! -f "ttylinux-uec-amd64-12.1_2.6.35-22_1.img" ] ; then
        echo "Extracting image"
	tar xfzv ttylinux-uec-amd64-12.1_2.6.35-22_1.tar.gz
fi

#TOKEN=`./obtain-token.sh`

export OS_TENANT_NAME=$SERVICE_TENANT_NAME
export OS_USERNAME=glance
export OS_PASSWORD=$SERVICE_PASSWORD
export OS_AUTH_URL='http://'$KEYSTONE_IP':5000/v2.0/'
export OS_REGION_NAME=RegionOne

export | grep OS_
#glance index

#exit 0
echo "Uploading kernel"
RVAL=`glance add name="ttylinux-kernel" is_public=true container_format=aki disk_format=aki < ttylinux-uec-amd64-12.1_2.6.35-22_1-vmlinuz`
KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`

echo "Uploading ramdisk"
RVAL=`glance add name="ttylinux-ramdisk" is_public=true container_format=ari disk_format=ari < ttylinux-uec-amd64-12.1_2.6.35-22_1-initrd`
RAMDISK_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`

echo "Uploading image"
glance add name="ttylinux" is_public=true container_format=ami disk_format=ami kernel_id=$KERNEL_ID ramdisk_id=$RAMDISK_ID < ttylinux-uec-amd64-12.1_2.6.35-22_1.img
