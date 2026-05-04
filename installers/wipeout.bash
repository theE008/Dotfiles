#!/bin/bash

# 1. Safety Check: Ensure a device was passed as an argument
if [ -z "$1" ]; then
    echo -e "\e[1;31mError:\e[0m No device specified."
    echo "Usage: ./install.sh <device_name> (e.g., sda or nvme0n1)"
    echo ""
    lsblk
    exit 1
fi

DEV="/dev/$1"

# 2. Safety Check: Ensure the device actually exists
if [ ! -b "$DEV" ]; then
    echo -e "\e[1;31mError:\e[0m $DEV is not a valid block device."
    exit 1
fi

# 3. Warning & Confirmation
echo -e "\e[1;33mWARNING:\e[0m About to WIPE $DEV and start Kavatron installation."
echo "Press ENTER to continue or Ctrl+C to abort..."
read _

# 4. Wipe and Partition
wipefs -a "$DEV"

echo -e "\n\e[1;34m[Step: Partitioning]\e[0m"
echo "1. Select GPT"
echo "2. Partition 1: 512M (Type: EFI System)"
echo "3. Partition 2: Rest of disk (Type: Linux Filesystem)"
sleep 3
cfdisk "$DEV"

# 5. Handle Partition Naming (Crucial for NVMe vs SATA)
# NVMe uses 'p1', SATA uses '1'
if [[ "$1" == nvme* ]]; then
    PART1="${DEV}p1"
    PART2="${DEV}p2"
else
    PART1="${DEV}1"
    PART2="${DEV}2"
fi

# 6. Formatting
echo -e "\n\e[1;34m[Step: Formatting]\e[0m"
mkfs.fat -F 32 "$PART1"
mkfs.ext4 "$PART2"

# 7. Mounting
mount "$PART2" /mnt
mount --mkdir "$PART1" /mnt/boot

# 8. Pacstrap (The Core)
echo -e "\n\e[1;34m[Step: Downloading the OS]\e[0m"
pacstrap -K /mnt base linux linux-firmware base-devel networkmanager nvim

# 9. Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# --- Copying the Kavatron Repo ---
echo -e "\n\e[1;34m[Step: Syncing Dotfiles]\e[0m"

# Create the user directory early so we have a place to put the files
mkdir -p /mnt/home/main/

# Copy the entire Dotfiles folder from your current live session to the new SSD
# We assume you are running this from ~/Dotfiles/installers
cp -r ~/Dotfiles /mnt/home/main/

# Ensure the chroot script is executable in its new home
chmod +x /mnt/home/main/Dotfiles/installers/chroot.bash
