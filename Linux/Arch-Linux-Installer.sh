#!/bin/bash
echo -e "\n\n\n\t\t\tArch Linux installer script\n\n\n"
echo -e "Select an keyboard layout\n1 - english-US(default)\n2 - portuguese-BR:\n"
read layout
if [ $layout = "2" ]
then
    loadkeys br-abnt2
fi
echo -e "\n\nUpdating system clock"
timedatectl set-ntp true

echo -e "\n\nChecking timedatectl status"
timedatectl status

echo -e "\n\nSetting time zone to America, Sao Paulo"
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

#Global inputs variables
username=""
password=""
disk=""
SWAP="" 

main(){    
    echo -e "\n\nSelect an option:\n"
    echo -e "1 - Create partitions in disks"
    echo -e "2 - Delete partitions in disks"
    echo -e "3 - Mount partitions"
    echo -e "4 - Install base packages"
    echo -e "5 - Finish install(run into Chroot)"
    echo -e "6 - Create new user"
    echo -e "7 - Set ROOT user password"
    echo -e "8 - Configurate system"
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
         prepare_partition
         ;;
        "4")
         install_base
         ;;
        "5")
         install_complement
         ;;
        "6")
         create_user
         ;;
        "7")
         username="root"; set_passwd
         ;;
        "8")
         system_config
         ;;
        "9")
         exit
         ;;
    esac    
    main
}
disk_create_partition(){

    root_size="30G"
    home_size=""
    getMem=$(grep MemTotal /proc/meminfo)
    swap=${getMem:9:${#getMem[@]}-3}
    swap=$(($swap/1000))"M"

    echo -e "\n\nInform the disk for create partitions:(ex: /dev/sdx)"
    read disk
    
    # echo -e "\n\nDo you want to format the entire disk for GPT?(Y/N)"
    # read response
    # if [[ $response = +(Y|y) ]];
    # then
    echo -e "\n\nFormating disk to GPT"
    (echo g; echo w) | fdisk $disk
    # fi
    
    lsblk
    echo -e "\n\nEnter the /ROOT size or press Enter to keep the default: (ex 30G, 500M ...)"
    read input
    
    if [[ $input != "" ]];
    then
        root_size=$input
    fi

    echo -e "\n\nEnter the /HOME size or press Enter to keep the default: (ex 30G, 500M ...)"
    read input

    if [[ $input != "" ]];
    then
        home_size=$input
    fi
    
    echo -e "\n\nCreating BOOT partition"
    (echo n; echo ; echo ; echo +512M; echo t; echo 1; echo w) | fdisk $disk    
    
    echo -e "\n\nCreating ROOT partition"
    (echo n; echo ; echo ; echo +$root_size; echo t; echo ; echo 24; echo w) | fdisk $disk    
    
    echo -e "\n\nCreating SWAP partition"
    (echo n; echo ; echo ; echo +$swap; echo t; echo ; echo 19; echo w) | fdisk $disk

    echo -e "\n\nCreating HOME partition"
    (echo n; echo ; echo ; echo +$home_size; echo t; echo ; echo 28; echo w) | fdisk $disk    

    

    echo -e "\n\nSuccessfully created partitions on $disk"
    (echo p) | fdisk $disk
}
disk_remove_partition (){  
    echo -e "\n\nInform the disk to remove partitions:(ex: /dev/sdx)"
    read d
    echo -e "\n\nInform the partition to remove:(ex: 1, 2, etc...)"
    read p

    echo -e "\n\nRemoving partition from $d"
    (echo d; echo $p; echo w) | fdisk $d
}
prepare_partition (){    
    
    echo -e "\n\nDo you want use dual boot?(Y/N)"
    read resp
    if [[ $resp = +(Y|y) ]];
    then
        echo -e "\n\nInform the partition of boot of Windows(EFI partition)(ex: /dev/sdz)"
        read boot
        mkdir /mnt/windows; mount $boot /mnt/windows
    fi

    echo -e "\n\nCreating directory and mounting BOOT"
    mkfs.fat -F32 -n BOOT $disk"1"
    mkdir -p /mnt/boot/efi; mount $disk"1" /mnt/boot/efi

    echo -e "\n\nMounting ROOT"
    (echo y) | mkfs.ext4 -L ROOT $disk"2"
    mount $disk"2" /mnt

    echo -e "\n\nCreating directory and mounting HOME"
    (echo y) | mkfs.ext4 -L HOME $disk"4"
    mkdir /mnt/home; mount $disk"4" /mnt/home

    echo -e "\n\nMounting SWAP"    
    mkswap -L SWAP $disk"3"
    swapon $disk"3"

    echo -e "\n\nSuccessfully created and assembled directories"
    lsblk
}
install_base(){

    
    # (echo Y) | pacman -Sy pacman-contrib

    # cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp
    # sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.bkp
    # rankmirrors /etc/pacman.d/mirrorlist.bkp > /etc/pacman.d/mirrorlist
    # rm /etc/pacman.d/mirrorlist.bkp

    echo -e "\n\nUpdating system"
    # (echo Y) | pacman -Syyu
    
    echo -e "\n\nInstalling base packages"
    pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd

    echo -e "\n\nAdd mounted disks on FSTAB file"
    rm /mnt/etc/fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    cat /mnt/etc/fstab

    echo -e "\n\nEntering new system"
    arch-chroot /mnt	
}
install_complement(){
    echo -e "\n\nValidating package signing"
    pacman-key --populate archlinux
    
    echo -e "\n\nInstaling essentials packages"
    (echo ; echo 1; echo Y) | pacman -S grub-efi-x86_64 efibootmgr os-prober pacman-contrib ntfs-3g intel-ucode alsa-utils 
    pulseaudio pulseaudio-alsa pavucontrol xorg-server xorg-xinit xorg-xrandr arandr mesa xf86-video-intel iprout2 networkmanager 
    wireless_tools ntp dhcpcd nano vim
    # Remove the comment to install these packages
    #(echo ; echo 1; echo Y) | pacman -S feh screenfetch vlc p7zip firefox noto-fonts git xbindkeys htop sddm lm-sensors acpi i3status i3lock i3-wm xfce4-terminal xorg-twm xterm xclock xorg-xinit 
    finish_install
} 
finish_install(){
    echo -e "\n\nInstalling GRUB"
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck

    echo -e "\n\nListing O.Ss"
    os-prober

    echo -e "\n\nWriting GRUB configuration"
    grub-mkconfig -o /boot/grub/grub.cfg
    
    echo -e "\n\nCompiling boot image"
    mkinitcpio -p linux
}

system_config(){

    echo -e "\n\nSetting time zone to America, Sao Paulo and time zone to Brazil"
    ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    
    echo -e "\n\nSetting clock and enabling ethernet"
    hwclock --systohc
    timedatectl set-ntp true
    timedatectl status
    systemclt enable dhcpcd.service
    systemclt start dhcpcd.service
    systemctl enable NetworkManager.service
    systemctl start NetworkManager.service
    systemctl start sddm.service
    systemctl enable sddm.service
    systemctl enable ntpd.service
    
    echo -e "\n\nSetting keyboard layout to br-abnt2"
    localectl set-keymap --no-convert br-abnt2
    localectl set-x11-keymap br abnt2
    
    echo -e "\n\nSetting language to pt_BR.UTF-8"
    sed -i 's/^#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen > /etc/locale.gen
    locale-gen
    echo LANG=pt_BR.UTF-8 > /etc/locale.conf
    echo KEYMAP=br-abnt2 > /etc/vconsole.conf
    echo ArchLinuxPC > /etc/hostname
    echo -e "127.0.0.1 localhost.localdomain localhost\n::1 localhost.localdomain localhost\n127.0.1.1 ArchLinuxPC.localdomain ArchLinuxPC" > /etc/hosts

    #configurate the current shell to selected language
    export LANG=pt_BR.UTF-8
    
    echo -e "\n\nEnabling MULTILIB repository"
    sed -i 's/^#[multilib]/[multilib]/g' /etc/pacman.conf > /etc/pacman.conf
    
}
create_user(){
    echo -e "\n\nEnter username"
    read username
    (echo ;) | useradd -m -g users -G wheel -s /bin/bash $username
    set_passwd
}
set_passwd(){
    echo -e "\n\nEnter password"
    read password
    (echo $password; echo $password; echo ) | passwd $username
}
main
