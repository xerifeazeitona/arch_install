#!/usr/bin/env bash

### Arch base install script
# largely based on https://gitlab.com/eflinux/arch-basic/-/blob/master/base-uefi.sh
#
# This script automates the configuration of:
# - time zone
# - localization
# - network configuration
# - root password
# - common packages installation
# - bootloader
# - startup services
# - replace zswap with zram
#
# It's highly recommended to change passwords, zram size and initramfs modules before running the script

## Time zone
ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime
hwclock --systohc

## Localization
sed -i 's/#en_US.UTF/en_US.UTF/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
#echo "KEYMAP=de_CH-latin1" >> /etc/vconsole.conf #set keyboard layout when necessary

## Network configuration
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts

## root password
echo root:unsafe_root | chpasswd

## common packages 
#pulseaudio (comment if using pipewire)
pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers avahi ntfs-3g sshfs btrfs-progs xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils man cups alsa-utils pulseaudio pavucontrol bash-completion openssh rsync reflector acpi acpi_call dnsmasq openbsd-netcat iptables-nft ipset firewalld flatpak nss-mdns acpid os-prober 

#pipewire (comment if using pulseaudio)
#pacman -S --noconfirm grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers avahi ntfs-3g sshfs btrfs-progs xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils man cups alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call dnsmasq openbsd-netcat iptables-nft ipset firewalld flatpak nss-mdns acpid os-prober 

# bare metal packages
#pacman -S --noconfirm bluez bluez-utils tlp sof-firmware

# video card packages
# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

## bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

## Startup services
systemctl enable NetworkManager
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid
#systemctl enable bluetooth  # Uncomment for bare metal
#systemctl enable tlp  # Uncomment for bare metal

## Replace zswap with zram
echo "zram" >> /etc/modules-load.d/zram.conf
echo "options zram num_devices=1" >> /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="2G" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules
echo "/dev/zram0 none swap defaults 0 0" >> /etc/fstab
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="zswap.enabled=0 /' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

## Add btrfs support to initramfs
sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -P

## User creation
useradd -m korporal
echo korporal:unsafe_user | chpasswd
usermod -aG users,wheel korporal
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers && visudo -c /etc/sudoers

printf "\e[1;32mDone! Type exit, umount -R /mnt and reboot.\n\e[0m"
