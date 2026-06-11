#!/bin/bash
set -euo pipefail

# Aero Linux - customize_airootfs.sh
# Runs inside the archiso chroot during ISO build
# Configures the live environment

# Set live environment defaults
echo "KEYMAP=us" > /etc/vconsole.conf
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "aero" > /etc/hostname
echo "127.0.1.1 aero.localdomain aero" >> /etc/hosts

# Enable services for live environment
systemctl enable NetworkManager
systemctl enable greetd

# Set zsh as default shell for root in live env
chsh -s /usr/bin/zsh root

# Create liveuser account (passwordless - no password set)
useradd -mG wheel,audio,video,input,storage,network liveuser
passwd -d liveuser
chsh -s /usr/bin/zsh liveuser
echo "liveuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-liveuser

# Issue/login screen branding
cat > /etc/issue <<'ISSUE'
\S
Aero Linux Live \v \r

Username: liveuser    Password: (none)
Type 'aero-install' to start the installer.
ISSUE

# Add auto-launch to .zshrc for liveuser
cat >> /home/liveuser/.zshrc <<'EOF'
# Auto-launch installer on login
if [[ -z "$AERO_INSTALLER_RAN" && -f /usr/local/bin/aero-install ]]; then
    export AERO_INSTALLER_RAN=1
    clear
    printf "\033[1;36m"
    printf "    █████╗ ███████╗██████╗  ██████╗ \n"
    printf "   ██╔══██╗██╔════╝██╔══██╗██╔═══██╗\n"
    printf "   ███████║█████╗  ██████╔╝██║   ██║\n"
    printf "   ██╔══██║██╔══╝  ██╔══██╗██║   ██║\n"
    printf "   ██║  ██║███████╗██║  ██║╚██████╔╝\n"
    printf "   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ \n"
    printf "\033[0m\n"
    printf "\n"
    printf "  Welcome to Aero Linux Live!\n"
    printf "\n"
    printf "  Type 'aero-install' to start the installer.\n"
    printf "\n"
fi
EOF

# Pre-deploy Hyprland config for liveuser (prevents autogen warning)
mkdir -p /home/liveuser/.config/hypr
cp -r /usr/share/aero/configs/hypr/* /home/liveuser/.config/hypr/
chown -R liveuser:liveuser /home/liveuser/.config/hypr

# Pre-deploy wallpaper for liveuser
mkdir -p /home/liveuser/.config/aero
cp /usr/share/backgrounds/aero/default.jpg /home/liveuser/.config/aero/wallpaper
chown -R liveuser:liveuser /home/liveuser/.config/aero

chown -R liveuser:liveuser /home/liveuser

# Clean pacman cache
pacman -Scc --noconfirm 2>/dev/null || true
rm -f /var/cache/pacman/pkg/*

# Create marker that this is a live environment
touch /etc/aero-live
