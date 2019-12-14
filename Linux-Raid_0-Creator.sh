#!/bin/bash
clear
echo -e "\n\n\n\t\t\tRAID-0 creation script\n\n\n"
echo -e "Before running this script the /dev/sda and /dev/sdb disks must be \nzeroed and the partition type GUID need be Linux RAID\n\n"
echo -e "These are the online disks in your system:\n"
fdisk -l

#read rsp
#
#if [[ $rsp = +(Y|y) ]];
#then
    echo -e "\n\nCreating a RAID-0 using the first partition of disks /dev/sda and /dev/sdb"
    if [ mdadm --create --verbose --level=0 --metadata=1.2 --raid-devices=2 $/dev/md/RAID-0 $/dev/sda1 $/dev/sdb1 ];
    then
        echo -e "\n\nRAID-0 successfully created on the following disks\n"
        fdisk /dev/sda p; fdisk /dev/sdb p
    else
        echo -e "\n\nCould not create RAID-0\n"
    fi
#fi
echo "Continue..."
read