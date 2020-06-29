#!/bin/bash
echo -e "\n\n\n\t\t\tRAID management script\n\n\n"
disks = ()
raid_name=""
n="0"
# disk1="0"
# disk2="0"
# disk3="0"
# disk4="0"
main(){
    echo -e "\n\nSelect an option:\n"
    echo -e "1 - Create partitions in disks"
    echo -e "2 - Delete partitions in disks"
    echo -e "3 - Create RAID-0"
    echo -e "4 - Create RAID-10"
    echo -e "5 - Delete RAID"
    echo -e "6 - Configure RAID"
    echo -e "7 - Create RAID partitions to install Linux (UEFI)"
    echo -e "8 - Show disks online"
    echo -e "9 - Prepare partitions to install Linux"
    echo -e "10 - Exit\n"
    read option        
    case $option in
        "1")
         disk_create_partition
         ;;
        "2")
         disk_remove_partition
         ;;
        "3")
         raid-0_creator
         ;;
        "4")
         raid-10_creator
         ;;
        "5")
         raid_remove
         ;;
        "6")
         raid_conf
         ;;
        "7")
         raid_partition
         ;;
        "8")
         clear
         echo -e "These are the online disks in your system:\n"
         fdisk -l
         ;;
        "9")
         prepare_partition
         ;;
        "10")
         exit
         ;;
    esac    
    main
}
raid-0_creator(){
    raid_name = "RAID-0"
    echo -e "\n\nCreating a RAID-0 using the first partition of selected disks"
    mdadm --create --verbose --level=0 --metadata=1.0 --raid-devices=2 /dev/md/$raid_name $disks[0]"1" $disks[1]"1"
}
raid-10_creator(){
    raid_name = "RAID-10"
    echo -e "\n\nCreating a RAID-10 using the first partition of selected disks"
    mdadm --create --verbose --level=10 --metadata=1.0 --raid-devices=2 /dev/md/$raid_name $disks[0]"1" $disks[1]"1"
}
raid_remove(){
    echo -e "\n\nRemoving the $raid_name"
    mdadm --stop /dev/md/$raid_name
    mdadm --remove /dev/md/$raid_name /dev/

    for ((cont=0; cont<${#disks[@]}; cont++));
    do 
    mdadm --remove ${disks[$cont]};
    mdadm --zero-superblock ${disks[$cont]}; 
    done 
}
raid_conf(){
    echo -e "\n\nWriting $raid_name config on /etc/mdadm.conf"
    rm /etc/mdadm.conf
    mdadm --detail --scan >> /etc/mdadm.conf
    echo -e "\n\nMounting $raid_name"
    mdadm --assemble --scan
    echo -e "\n\nEnabling for write"
    mdadm --manage -w /dev/md/$raid_name
}
raid_partition(){
    echo -e "\n\nFormating $raid_name to GPT"
    (echo g; echo w) | fdisk /dev/md/$raid_name

    echo -e "\n\nType size of ROOT partition:(ex: 30G, 500M...)"
    read root
    echo -e "\n\nType size of HOME partition:(ex: 30G, 500M...)"
    read home
    echo -e "\n\nType size of SWAP partition:(ex: 8G, 500M...)"
    read swap

    echo -e "\n\nPreparing BOOT partition on /dev/md/$raid_name p1"
    (echo n; echo 1; echo ; echo +512M; echo t; echo 1; echo w) | fdisk /dev/md/$raid_name

    echo -e "\n\nPreparing ROOT partition on /dev/md/$raid_name p2"
    (echo n; echo 2; echo ; echo +$root; echo t; echo 2; echo 24; echo w) | fdisk /dev/md/$raid_name

    echo -e "\n\nPreparing HOME partition on /dev/md/$raid_name p3"
    (echo n; echo 3; echo ; echo +$home; echo t; echo 3; echo 28; echo w) | fdisk /dev/md/$raid_name

    echo -e "\n\nPreparing SWAP partition on /dev/md/$raid_name p4"
    (echo n; echo 4; echo ; echo +$swap; echo t; echo 4; echo 19; echo w) | fdisk /dev/md/$raid_name

    echo -e "\n\nSuccessfully created partitions on /dev/md/$raid_name"
    fdisk /dev/md/$raid_name -l
}
disk_create_partition(){
    clear
    echo -e "These are the online disks in your system:\n"
    fdisk -l
    
    echo -e "\n\nInform one disk for create partition:(ex: /dev/sdX)"
    read disks[n]
    n=$n+1

    echo -e "\n\nDo you want create a new partition?(Y/N)"
    read response
    if [[ $response = +(Y|y) ]];
    then
        disk_create_partition()
    fi

    echo -e "\n\nInform size of partitions:(ex: 70M, 70G...)"
    read size

    for ((cont=0; cont<${#disks[@]}; cont++));
    do 
    echo -e "\n\nFormat to GPT and create an $size partition on ${disks[$cont]}"
    (echo g; echo n; echo ; echo ; echo +$size; echo t; echo 29; echo w) | fdisk ${disks[$cont]}; 
    done 
}
disk_remove_partition (){
 
    for ((cont=0; cont<${#disks[@]}; cont++));
    do 
    echo -e "Removing partition from ${disks[$cont]}"
    (echo d; echo w) | fdisk ${disks[$cont]}; 
    done 

}
prepare_partition (){
    # mdadm --detail /dev/md/RAID-0 | grep 'Chunk Size'
    # echo -e "\n\nType the value of Chunk Size in bytes:(ex: 512K => 512000)"
    # read chunk

    getSize=$(mdadm --detail /dev/md/RAID-0 | grep 'Chunk Size')
    chunk=${getSize:20:${#getSize[@]}-2}
    chunk=$(($chunk*1000))
    
    echo -e "\n\nCreating directory and mounting ROOT"
    (echo y) | mkfs.ext4 -v -L ROOT -m 0.5 -b 4096 -E stride=$((chunk/4096)),stripe-width=$(((chunk/4096)*2)) /dev/md/RAID-0p2 #raid 0
    (echo y) | mkfs.ext4 -v -L ROOT -m 0.5 -b 4096 -E stride=$((chunk/4096)) /dev/md/RAID-0p2 #raid 10
    mkdir /mnt; mount /dev/md/RAID-0p2 /mnt

    echo -e "\n\nCreating directory and mounting BOOT"
    mkfs.fat -F32 -v -n BOOT /dev/md/RAID-0p1
    mkdir -p /mnt/boot/efi; mount /dev/md/RAID-0p1 /mnt/boot/efi

    echo -e "\n\nCreating directory and mounting HOME"
    (echo y) | mkfs.ext4 -v -L HOME -m 0.5 -b 4096 -E stride=$((chunk/4096)),stripe-width=$(((chunk/4096)*2)) /dev/md/RAID-0p3 #raid 0
    (echo y) | mkfs.ext4 -v -L HOME -m 0.5 -b 4096 -E stride=$((chunk/4096)) /dev/md/RAID-0p3 #raid 10
    mkdir /mnt/home; mount /dev/md/RAID-0p3 /mnt/home

    echo -e "\n\nMounting SWAP"
    mkswap -L SWAP /dev/md/RAID-0p4
    swapon /dev/md/RAID-0p4

    echo -e "\n\nSuccessfully created and assembled directories"
    lsblk /dev/md/$raid_name
}
main