#!/bin/bash
clear
main(){
    echo -e "\n\n\n\t\t\tRAID-0 management script\n\n\n"
    echo -e "Before running this script the /dev/sda and /dev/sdb disks must be \nzeroed and the partition type GUID need be Linux RAID\n\n"
    echo -e "These are the online disks in your system:\n"
    fdisk -l
    echo -e "\n\nSelect an option:\n1 - Creat RAID-0\n2 - Delete RAID-0\n\n"
    read option
    case $option in
        "1")
         raid_creator
         ;;
        "2")
         raid_remove
         ;;
    esac
}
raid_creator(){
    echo -e "\n\nCreating a RAID-0 using the first partition of disks /dev/sda and /dev/sdb"
    mdadm --create --verbose --level=0 --metadata=1.2 --raid-devices=2 /dev/md/RAID-0 /dev/sda1 /dev/sdb1
    echo -e "\n\nRAID-0 successfully created on /dev/md/RAID-0\n"
    fdisk /dev/md/RAID-0 -l
}
raid_remove(){
    echo -e "\n\nRemoving a RAID-0 from the first partition of disks /dev/sda and /dev/sdb"
    mdadm --stop /dev/md/RAID-0
    mdadm --remove /dev/md/RAID-0
    mdadm --zero-superblock /dev/sda1 /dev/sdb1
    echo -e "\n\nRAID-0 successfully removed from /dev/md/RAID-0\n"
    fdisk -l
}
#fi
echo "Continue..."
read