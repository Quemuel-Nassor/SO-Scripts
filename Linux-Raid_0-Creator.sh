#!/bin/bash

echo -e "\n\n\n\t\t\tRAID-0 creation script\n\n\n"

echo -e "These are the online disks in your system:\n"
fdisk -l

echo -e "Do you want create the partitions manualy?(Y/N)"
read rsp

if [[ $rsp = +(Y|y) ]];
then
    echo -e "Creating a partition of 30GB on first position of /dev/sda\n"
    if [ fdisk /dev/sda n p 1 2048 +30G ];
    then
        echo -e "Partição criada com sucesso\n"
        fdisk /dev/sda p
    elif
    then
        echo -e "Não foi possível criar a partição "
    fi
else
    echo -e "\n\nPartitions will be created automatically\n"
fi
echo "Continue..."
read