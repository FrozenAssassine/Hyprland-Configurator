#!/bin/bash

# ============================
# Constants
# ============================
CNT="[INFO]"
COK="[OK]"
CER="[ERROR]"
CAT="[NOTICE]"
INSTLOG="install.log"

# ============================
# Package Groups
# ============================
prep_stage=(
    qt5-wayland qt5ct qt6-wayland qt6ct qt5-svg qt5-quickcontrols2 qt5-graphicaleffects
    gtk3 polkit-gnome pipewire wireplumber jq wl-clipboard cliphist python-requests pacman-contrib
)

nvidia_stage=(
    linux-headers nvidia-dkms nvidia-settings libva libva-nvidia-driver-git
)

install_stage=(
    kitty mako waybar swww swaylock-effects swayidle wlogout
    xdg-desktop-portal-hyprland swappy grim slurp thunar btop firefox thunderbird mpv
    pamixer pavucontrol brightnessctl bluez bluez-utils blueman network-manager-applet
    gvfs thunar-archive-plugin file-roller papirus-icon-theme ttf-jetbrains-mono-nerd
    noto-fonts-emoji lxappearance xfce4-settings nwg-look sddm rofi rofi-emoji
    tesseract discord visual-studio-code-bin hyprpaper blender inkscape ttf-fantasque-sans-mono
)

# ============================
# Functions
# ============================
show_progress() {
    while ps -p "$1" &> /dev/null; do
        echo -n "."
        sleep 2
    done
    echo -e "\nDone!"
    sleep 1
}

install_software() {
    if yay -Q "$1" &>> "$INSTLOG"; then
        echo -e "$COK - $1 is already installed."
    else
        echo -en "$CNT - Installing $1..."
        yay -S --noconfirm "$1" &>> "$INSTLOG" &
        show_progress $!
        if yay -Q "$1" &>> "$INSTLOG"; then
            echo -e "\e[1A\e[K$COK - $1 installed."
        else
            echo -e "\e[1A\e[K$CER - Failed to install $1. Check $INSTLOG"
            exit 1
        fi
    fi
}

# ============================
# Start
# ============================

clear
echo -e "$CNT - Starting Hyprland installation..."

read -rep $'[\e[1;33mACTION\e[0m] - Continue? (y/n) ' CONTINST
if [[ ! $CONTINST =~ ^[Yy]$ ]]; then
    echo -e "$CNT - Exiting."
    exit
fi

sudo touch /tmp/hyprinstall.tmp

# Check for NVIDIA GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    ISNVIDIA=true
else
    ISNVIDIA=false
fi

# Disable WiFi powersave
read -rep $'[\e[1;33mACTION\e[0m] - Disable WiFi powersave? (y/n) ' WIFI
if [[ $WIFI =~ ^[Yy]$ ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    echo -e "$CNT - Creating $LOC"
    echo -e "[connection]\nwifi.powersave = 2" | sudo tee "$LOC" &>> "$INSTLOG"
    echo -en "$CNT - Restarting NetworkManager..."
    sudo systemctl restart NetworkManager &>> "$INSTLOG"
    sleep 6
    echo -e "\e[1A\e[K$COK - NetworkManager restarted."
fi

# yay install
if ! command -v yay &> /dev/null; then
    echo -en "$CNT - Installing yay..."
    git clone https://aur.archlinux.org/yay.git &>> "$INSTLOG"
    pushd yay
    makepkg -si --noconfirm &>> ../"$INSTLOG"
    popd
    if ! command -v yay &> /dev/null; then
        echo -e "\e[1A\e[K$CER - yay install failed."
        exit 1
    else
        echo -e "\e[1A\e[K$COK - yay installed."
        yay -Suy --noconfirm &>> "$INSTLOG"
    fi
fi

# Install packages
read -rep $'[\e[1;33mACTION\e[0m] - Install packages now? (y/n) ' INST
if [[ $INST =~ ^[Yy]$ ]]; then

    echo -e "$CNT - Installing preparation packages..."
    for pkg in "${prep_stage[@]}"; do
        install_software "$pkg"
    done

    if [[ "$ISNVIDIA" == true ]]; then
        echo -e "$CNT - Installing NVIDIA packages..."
        for pkg in "${nvidia_stage[@]}"; do
            install_software "$pkg"
        done

        sudo sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
        echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf &>> "$INSTLOG"
    fi

    echo -e "$CNT - Installing Hyprland..."
    install_software hyprland

    echo -e "$CNT - Installing main software..."
    for pkg in "${install_stage[@]}"; do
        install_software "$pkg"
    done

    echo -e "$CNT - Enabling Bluetooth service..."
    sudo systemctl enable --now bluetooth.service &>> "$INSTLOG"

    echo -e "$CNT - Enabling SDDM login manager..."
    sudo systemctl enable sddm &>> "$INSTLOG"

    echo -e "$CNT - Removing conflicting portals..."
    yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>> "$INSTLOG"
fi

# Copy config
echo -e "$CNT - Copying config files..."
cp -r .config/* ~/.config/
echo "$COK - Copied config to ~/.config"

# Done
echo -e "$COK - Installation complete."

if [[ "$ISNVIDIA" == true ]]; then 
    echo -e "$CAT - Reboot now to apply NVIDIA changes. Type 'reboot' to proceed."
    exit
fi

read -rep $'[\e[1;33mACTION\e[0m] - Start Hyprland via SDDM now? (y/n) ' HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    sudo systemctl start sddm &>> "$INSTLOG"
else
    echo -e "$CNT - You can start Hyprland later with: sudo systemctl start sddm"
    exit
fi