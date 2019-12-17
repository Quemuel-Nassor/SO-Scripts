#!/bin/bash
echo -e "\n\n\n\t\t\tRAID-0 management script\n\n\n"
disk1="0"
disk2="0"
main(){
    echo -e "\n\nSelect an option:\n"
    echo -e "1 - Create partitions in disks"
    echo -e "2 - Delete partitions in disks"
    echo -e "3 - Create RAID-0"
    echo -e "4 - Delete RAID-0"
    echo -e "5 - Configure RAID-0"
    echo -e "6 - Create RAID partitions to install Linux"
    echo -e "7 - Show disks online"
    echo -e "8 - Prepare partitions to install Linux"
    echo -e "9 - Exit\n"
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
         clear
         echo -e "These are the online disks in your system:\n"
         fdisk -l
         ;;
        "8")
         prepare_partition
         ;;
        "9")
         exit
         ;;
    esac    
    main
}
raid_creator(){
    echo -e "\n\nInform the fist disk for RAID-0:(ex: /dev/sdX)"
    read disk1
    echo -e "\n\nInform the second disk for RAID-0:(ex: /dev/sdY)"
    read disk2   
    echo -e "\n\nCreating a RAID-0 using the first partition of disks $disk1 and $disk2"
    echo $disk1"1"
    mdadm --create --verbose --level=0 --metadata=1.0 --raid-devices=2 /dev/md/RAID-0 $disk1"1" $disk2"1"
}
raid_remove(){
    echo -e "\n\nRemoving a RAID-0 from the first partition of disks $disk1 and $disk2"
    mdadm --stop /dev/md/RAID-0
    mdadm --remove /dev/md/RAID-0
    mdadm --zero-superblock $disk1 $disk2
}
raid_conf(){
    echo -e "\n\nWriting RAID-0 config on /etc/mdadm.conf"
    rm /etc/mdadm.conf
    mdadm --detail --scan >> /etc/mdadm.conf
    echo -e "\n\nMounting RAID-0"
    mdadm --assemble --scan
    echo -e "\n\nEnabling for write"
    mdadm --manage -w /dev/md/RAID-0
}
raid_partition(){
    echo -e "\n\nFormating RAID-0 to GPT"
    (echo g; echo w) | fdisk /dev/md/RAID-0

    echo -e "\n\nPreparing BOOT partition on /dev/md/RAID-0p1"
    (echo n; echo 1; echo ; echo +512M; echo t; echo 1; echo w) | fdisk /dev/md/RAID-0

    echo -e "\n\nPreparing ROOT partition on /dev/md/RAID-0p2"
    (echo n; echo 2; echo ; echo +30G; echo t; echo 2; echo 24; echo w) | fdisk /dev/md/RAID-0

    echo -e "\n\nPreparing HOME partition on /dev/md/RAID-0p3"
    (echo n; echo 3; echo ; echo +30G; echo t; echo 3; echo 28; echo w) | fdisk /dev/md/RAID-0

    echo -e "\n\nPreparing SWAP partition on /dev/md/RAID-0p4"
    (echo n; echo 4; echo ; echo +8G; echo t; echo 4; echo 19; echo w) | fdisk /dev/md/RAID-0

    echo -e "\n\nSuccessfully created partitions on /dev/md/RAID-0"
    fdisk /dev/md/RAID-0 -l
}
disk_create_partition(){
    echo -e "\n\nPress enter to keep previously defined disks"
    echo -e "\n\nInform the fist disk for create partition:(ex: /dev/sdX)"
    read disk1
    echo -e "\n\nInform the second disk for create partition:(ex: /dev/sdY)"
    read disk2
    echo -e "\n\nCreating an 70G GPT partition on /dev/sda"
    (echo g; echo n; echo 1; echo ; echo +70G; echo t; echo 29; echo w) | fdisk $disk1
    echo -e "\n\nCreating an 70G GPT partition on /dev/sdb"
    (echo g; echo n; echo 1; echo ; echo +70G; echo t; echo 29; echo w) | fdisk $disk2
}
disk_remove_partition (){
    echo -e "\n\nPress enter to keep previously defined disks"
    echo -e "\n\nInform the fist disk for remove partition:(ex: /dev/sdX)"
    read disk1
    echo -e "\n\nInform the second disk for remove partition:(ex: /dev/sdY)"
    read disk2         
    echo -e "\n\nRemoving partition from /dev/sda"
    (echo d; echo w) | fdisk disk1
    echo -e "\n\nRemoving partition from /dev/sdb"
    (echo d; echo w) | fdisk disk2
}
prepare_partition (){
    mdadm --detail /dev/md/RAID-0 | grep 'Chunk Size'
    echo -e "\n\nType the value of Chunk Size in bytes:(ex: 512K => 512000)"
    read chunk
    echo -e "\n\nCreating directory and mounting BOOT"
    mkfs.fat -F32 -v -n BOOT /dev/md/RAID-0p1
    mkdir -p /mnt/boot/efi; mount /dev/md/RAID-0p1 /mnt/boot/efi

    echo -e "\n\nCreating directory and mounting ROOT"
    (echo y) | mkfs.ext4 -v -L ROOT -m 0.5 -b 4096 -E stride=$((chunk/4096)),stripe-width=$(((chunk/4096)*2)) /dev/md/RAID-0p2
    mkdir /mnt; mount /dev/md/RAID-0p2 /mnt

    echo -e "\n\nCreating directory and mounting HOME"
    (echo y) | mkfs.ext4 -v -L HOME -m 0.5 -b 4096 -E stride=$((chunk/4096)),stripe-width=$(((chunk/4096)*2)) /dev/md/RAID-0p3
    mkdir /mnt/home; mount /dev/md/RAID-0p3 /mnt/home

    echo -e "\n\nMounting SWAP"
    mkswap -L SWAP /dev/md/RAID-0p4
    swapon /dev/md/RAID-0p4

    echo -e "\n\nSuccessfully created and assembled directories"
    lsblk /dev/md/RAID-0
}
main