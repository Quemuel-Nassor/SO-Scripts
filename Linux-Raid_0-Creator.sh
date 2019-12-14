#!/bin/bash
clear
echo -e "\n\n\n\t\t\tRAID-0 creation script\n\n\n"

echo -e "These are the online disks in your system:\n"
fdisk -l

echo -e "\n\nDo you want to create partitions automatically?(Y/N)"
read rsp

if [[ $rsp = +(N|n) ]];
then
    echo -e "\n\nCreating a partition of 70GB on first position of disks /dev/sda and /dev/sdb"
    if [ sfdisk /dev/sda < disk-conf && sfdisk /dev/sdb < disk-conf ];
    then
        echo -e "\n\nPartition successfully created on the following disks\n"
        fdisk /dev/sda p; fdisk /dev/sdb p
    else
        echo -e "\n\nCould not create partitions\n"
    fi
fi
echo "Continue..."
read