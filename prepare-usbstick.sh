#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Find mounted partitions
TEST="$(mount|grep $1|awk '{print $1}')"
echo $TEST

# Unmount them
TEST="$(umount $TEST)"
echo $TEST

# Modify partitions on USB Stick
TEST="$(fdisk $1 < partition.usb)"
echo $TEST

# Create swap filesystem
SWAPPART=$1"1"
DATAPART=$1"2"
TEST="$(mkswap $SWAPPART)"
echo $TEST

# Create data filesystem
TEST="$(mkfs.btrfs $DATAPART)"
echo $TEST
