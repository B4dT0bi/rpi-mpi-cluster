#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Find mounted partitions
TEST="$(mount|grep $1|awk '{print $1}')"

# Unmount them
TEST="$(umount $TEST)"

# Modify partitions on SD card
echo "Partitioning the sd card..."
TEST="$(fdisk $1 < partition.sd)"

# Create vfat filesystem
VFATPART=$1"p1"
DATAPART=$1"p2"
echo "Create vfat filesystem on $VFATPART"
TEST="$(mkfs.vfat $VFATPART)"

# Create data filesystem
echo "Create ext4 filesystem on $DATAPART"
TEST="$(mkfs.ext4 $DATAPART)"

rm -rf /tmp/archboot
rm -rf /tmp/archroot

mkdir /tmp/archboot
mkdir /tmp/archroot
mount $VFATPART /tmp/archboot
mount $DATAPART /tmp/archroot

if [ ! -f ArchLinuxARM-rpi-2-latest.tar.gz ]; then
  echo "Downloading latest ArchLinux for Raspberry Pi 2"
  wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
fi

echo "Unpacking ArchLinux to SD Card..."
bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C /tmp/archroot
sync
echo "Copying boot files to SD Card boot partition..."
mv /tmp/archroot/boot/* /tmp/archboot

echo "Copying aufs-includes and modules to SD card..."
tar -xzf aufs-modules.tar.gz -C /tmp/archroot

umount /tmp/archboot /tmp/archroot 
echo "Done."
