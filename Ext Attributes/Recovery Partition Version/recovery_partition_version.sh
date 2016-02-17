#!/bin/bash


mountpoint="/Volumes/.tempmount"

# create hidden folder to mount disk
mkdir "$mountpoint"

# find recovery HD
RecoveryHDName="Recovery HD " 
RecoveryHDID=`/usr/sbin/diskutil list | grep "$RecoveryHDName" | awk 'END { print $NF }'`
echo "RecoveryHDID = $RecoveryHDID"
# mount the recovery hd
/usr/sbin/diskutil mount readOnly -mountPoint "$mountpoint" /dev/"$RecoveryHDID"

# pull the version info out
version=`cat /Volumes/.tempmount/com.apple.recovery.boot/SystemVersion.plist | awk ' /ProductVersion/ { getline; print $0 }' | sed 's/[A-Za-z<>\/]//g'`

# unmount recovery hd
/usr/sbin/diskutil unmount $mountpoint


### Create Application receipt folder
if [ ! -d /Library/Receipts/corp ]; then
mkdir /Library/Receipts/corp
fi
# update receipt - Overwrites if exists.
echo "$version" > /Library/Receipts/corp/RecoveryHDVersion
