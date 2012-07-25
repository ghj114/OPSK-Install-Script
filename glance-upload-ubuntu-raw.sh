#!/bin/bash

# Import Settings
. settings

#if [ ! -f "vmlinuz-2.6.18-238.el5" ] ; then
#	echo "can not find vmlinuz-2.6.18-238.el5!"
#	exit -1
#fi
#
#if [ ! -f "initrd-2.6.18-238.el5.img" ] ; then
#	echo "can not find initrd-2.6.18-238.el5.img!"
#	exit -1
#fi

#if [ ! -f "centos5.6.final.img" ] ; then
#	echo "can not find centos5.6.final.img!"
#	exit -1
#fi

#if [ ! -f "ubuntu-11.10.img" ] ; then
#	echo "can not find ubuntu-11.10.img!"
#	exit -1
#fi


if [ ! -f "ubuntu-12.04.img" ] ; then
	echo "can not find ubuntu-12.04.img!"
	exit -1
fi

TOKEN=`./obtain-token.sh`

#echo "Uploading kernel"
#RVAL=`glance -A $TOKEN add name="centos5.6-kernel" is_public=true container_format=aki disk_format=aki < vmlinuz-2.6.18-238.el5`
#KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`
#
#echo "Uploading ramdisk"
#RVAL=`glance -A $TOKEN add name="centos5.6-ramdisk" is_public=true container_format=ari disk_format=ari < initrd-2.6.18-238.el5.img`
#RAMDISK_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`
#
#echo "Uploading image"
#glance -A $TOKEN add name="centos5.6" is_public=true container_format=ami disk_format=ami kernel_id=$KERNEL_ID ramdisk_id=$RAMDISK_ID < centos5.6.final.img

echo "Uploading raw image"
#glance add -A $TOKEN name="ubuntu-11.10.img" is_public=true disk_format=raw <  ubuntu-11.10.img
glance add -A $TOKEN name="ubuntu-12.04.img" is_public=true disk_format=raw <  ubuntu-12.04.img

