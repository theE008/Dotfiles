#!/bin/bash

# --- Phase 4: System Configuration ---

# 1. Timezone (Adjust 'America/Sao_Paulo' to your preference)
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

# 2. Localization
# This uses sed to uncomment the line instead of opening nvim manually
sed -i 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf

# 3. Networking
echo "Kavatron" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   Kavatron8K.localdomain Kavatron8K" >> /etc/hosts

# --- Phase 5: Users & Permissions ---

# 4. Root Password
echo "Setting root password..."
passwd

# 5. User Creation
useradd -m -G wheel main
echo "Setting password for user 'main'..."
passwd main

# 6. Sudoers (Uncomment wheel group)
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# --- Phase 6: Bootloader ---

# 7. GRUB Installation
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# 8. Enable Services
systemctl enable NetworkManager

echo -e "\n\e[1;32mChroot configuration complete!\e[0m"
exit
