#!/bin/bash
echo -e "\n\n\n\t\t\tRAID-0 management script\n\n\n"
main(){
    echo -e "These are the online disks in your system:\n"
    fdisk -l
    echo -e "\n\nSelect an option:\n"
    echo -e "1 - Create partitions in disks"
    echo -e "2 - Delete partitions in disks"
    echo -e "3 - Create RAID-0"
    echo -e "4 - Delete RAID-0"
    echo -e "5 - Configure RAID-0"
    echo -e "6 - Create RAID partitions to install Linux"
    echo -e "7 - Exit\n"
    read option        
    case $option in
        "1")
         disk_create_partition
         ;;
        "2")
         disk_remove_partition
         ;;
        "3")
         raid_creator
         ;;
        "4")
         raid_remove
         ;;
        "5")
         raid_conf
         ;;
        "6")
         raid_partition
         ;;
        "7")
         exit
         ;;
    esac    
    main
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
raid_conf(){
    echo -e "\n\nWriting RAID-0 config on /etc/mdadm.conf"
    mdadm --detail --scan >> /etc/mdadm.conf
    echo -e "\n\nMounting RAID-0"
    mdadm --assemble --scan
}
raid_partition(){
    echo -e "\n\nCreating BOOT partition on /dev/md/RAID-0p1"
    (echo n; echo 1; echo ; echo +512M; echo t; echo 1; echo w) | fdisk /dev/md/RAID-0
    echo -e "\n\nCreating ROOT partition on /dev/md/RAID-0p2"
    (echo n; echo 2; echo ; echo +10G; echo t; echo 2; echo 24; echo w) | fdisk /dev/md/RAID-0
    echo -e "\n\nCreating HOME partition on /dev/md/RAID-0p3"
    (echo n; echo 3; echo ; echo +20G; echo t; echo 3; echo 28; echo w) | fdisk /dev/md/RAID-0
    echo -e "\n\nCreating HOME partition on /dev/md/RAID-0p4"
    (echo n; echo 4; echo ; echo +8G; echo t; echo 4; echo 19; echo w) | fdisk /dev/md/RAID-0
    echo -e "\n\nSuccessfully created partitions on /dev/md/RAID-0"
    fdisk /dev/md/RAID-0 -l
}
disk_create_partition(){
    echo -e "\n\nCreating an 70G partition on /dev/sda"
    (echo g; echo n; echo 1; echo ; echo +70G; echo t; echo 29; echo w) | fdisk /dev/sda
    echo -e "\n\nCreating an 70G partition on /dev/sdb"
    (echo g; echo n; echo 1; echo ; echo +70G; echo t; echo 29; echo w) | fdisk /dev/sdb
}
disk_remove_partition (){         
    echo -e "\n\nRemoving partition from /dev/sda"
    (echo d; echo w) | fdisk /dev/sda
    echo -e "\n\nRemoving partition from /dev/sdb"
    (echo d; echo w) | fdisk /dev/sdb
}
main