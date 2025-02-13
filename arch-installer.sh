#!/bin/bash

#
# Author: Wartuu
# License: MIT
#
# Before using this script make sure you are connected to the network
# and you have configured all settings below.
#

# CONFIG

DISK="/dev/sda"
SWAP_SIZE="16G"
ADDITIONAL_PACKAGES="neofetch"

TIMEZONE="Europe/Warsaw"

LOCALES=("en_US.UTF-8 UTF-8" "pl_PL.UTF-8 UTF-8")
KEYBOARD_LAYOUT="pl"

HOSTNAME="tpad"
ROOT_PASSWORD="Admin123!"

HOME_USERNAME="wartuu"
HOME_PASSWORD="Admin123!"

# [Y]es / [N]o        !!! CASE SENSITIVE !!!
SETUP_DOTFILES="Y"

# END CONFIG





# Set keyboard layout
loadkeys "$KEYBOARD_LAYOUT"

echo "Wiping all partitions on $DISK..."
wipefs -a "$DISK"
sgdisk --zap-all "$DISK"

echo "Creating partitions..."
fdisk "$DISK" <<EOF
g
n
1

+100M
n
2

+${SWAP_SIZE}
n
3


t
1
1
t
2
19
w
EOF

echo "Formatting partitions..."
mkfs.fat -F 32 "${DISK}1"
mkswap "${DISK}2"
mkfs.ext4 "${DISK}3"

echo "Mounting partitions..."
mount "${DISK}3" /mnt
mkdir -p /mnt/boot/efi
mount "${DISK}1" /mnt/boot/efi
swapon "${DISK}2"

echo "Installing base system..."
pacstrap /mnt base linux linux-firmware sof-firmware base-devel grub efibootmgr networkmanager bluez bluez-utils blueman network-manager-applet nano ${ADDITIONAL_PACKAGES:-} --noconfirm

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "Setting timezone..."
arch-chroot /mnt ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
arch-chroot /mnt hwclock --systohc

echo "Configuring locale..."
for locale in "${LOCALES[@]}"; do
  sed -i "/^#${locale}/s/^#//" /mnt/etc/locale.gen
done
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

echo "Setting keymap..."
echo "KEYMAP=${KEYBOARD_LAYOUT}" > /mnt/etc/vconsole.conf

echo "Setting hostname..."
echo "$HOSTNAME" > /mnt/etc/hostname

echo "Setting root password..."
echo "root:${ROOT_PASSWORD}" | arch-chroot /mnt chpasswd

echo "Creating user: ${HOME_USERNAME}"
arch-chroot /mnt useradd -m -G wheel -s /bin/bash "${HOME_USERNAME}"
echo "${HOME_USERNAME}:${HOME_PASSWORD}" | arch-chroot /mnt chpasswd

echo "Enabling sudo for WHEEL group..."
echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers
arch-chroot /mnt pacman -S sudo --noconfirm

echo "Enabling essential services..."
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable bluetooth

echo "Installing and configuring GRUB..."
arch-chroot /mnt grub-install ${DISK}
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# YAY

arch-chroot /mnt bash -c "
  git clone https://aur.archlinux.org/yay.git /home/${HOME_USERNAME}/yay &&
  cd /home/${HOME_USERNAME}/yay &&
  sudo -u ${HOME_USERNAME} makepkg -si --noconfirm &&
  cd .. &&
  rm -rf yay
"

echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf
arch-chroot /mnt pacman -Sy --noconfirm

# BASE + THINKPAD SPECIFIC
arch-chroot /mnt pacman -S acpi acpid tlp --noconfirm
arch-chroot /mnt pacman -S alacritty git base-devel neovim zsh --noconfirm
arch-chroot /mnt pacman -S ttf-jetbrains-mono-nerd otf-font-awesome ttf-font-awesome ttf-fantasque-nerd --noconfirm

arch-chroot /mnt chsh -s $(which zsh) ${HOME_USERNAME}
# WAYLAND
arch-chroot /mnt pacman -S hyprland wayland rofi waybar hyprpaper wl-clipboard mako lxappearance greetd greetd-tuigreet  --noconfirm
arch-chroot /mnt pacman -S pavucontrol blueman --noconfirm
arch-chroot /mnt systemctl enable greetd.service

cp ./greetd/config.toml /mnt/etc/greetd/config.toml

arch-chroot /mnt yay -S wlogout --noconfirm
arch-chroot /mnt yay -S swaylock-effects-git --noconfirm
arch-chroot /mnt yay -S pfetch --noconfirm

# ESSENTIALS
arch-chroot /mnt pacman -S thunar thunar-archive-plugin zathura file-roller vlc firefox --noconfirm

# GAMING
arch-chroot /mnt pacman -S vulkan-intel lib32-vulkan-intel mesa vulkan-tools lib32-mesa steam --noconfirm

# TOOLS
arch-chroot /mnt yay -S visual-studio-code-bin --noconfirm
arch-chroot /mnt pacman -S intellij-idea-community-edition --noconfirm



if [[ "$SETUP_DOTFILES" == "Y" ]]; then
    echo "Setting up dotfiles..."
    cp -r ./config/* /mnt/home/${HOME_USERNAME}/.config/

    chmod +x /mnt/home/${HOME_USERNAME}/.config/swaylock/lock.sh

    arch-chroot /mnt chown -R ${HOME_USERNAME}:${HOME_USERNAME} /home/wartuu/.config/
else
    echo "Skipping dotfiles setup."
fi

umount -a

echo "Installation complete! You can now reboot."
