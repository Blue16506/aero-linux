#!/bin/bash
set -euo pipefail

# Aero Linux - Hardware Detection
# Detects GPU, CPU, and other hardware and applies optimizations

AERO_LOG="/var/log/aero-hardware.log"

exec > >(tee -a "$AERO_LOG") 2>&1

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }

# Detect GPU
GPU_VENDOR=""
if lspci | grep -i vga | grep -qi nvidia; then
    GPU_VENDOR="nvidia"
elif lspci | grep -i vga | grep -qi "amd\|ati"; then
    GPU_VENDOR="amd"
elif lspci | grep -i vga | grep -qi intel; then
    GPU_VENDOR="intel"
fi

info "Detected GPU: ${GPU_VENDOR:-unknown}"

if [[ "$GPU_VENDOR" == "nvidia" ]]; then
    info "NVIDIA detected – installing drivers..."
    pacman -S --noconfirm nvidia nvidia-utils nvidia-settings 2>/dev/null || \
        warn "Could not install NVIDIA drivers"

    mkdir -p /etc/pacman.d/hooks
    cat > /etc/pacman.d/hooks/nvidia.hook <<'HOOK'
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=usr/lib/modules/*/vmlinuz

[Action]
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/usr/bin/mkinitcpio -P
HOOK
fi

if [[ "$GPU_VENDOR" == "intel" ]]; then
    info "Intel GPU detected – installing VA-API drivers..."
    pacman -S --noconfirm intel-media-driver 2>/dev/null || true
fi

if [[ "$GPU_VENDOR" == "amd" ]]; then
    info "AMD GPU detected – installing Vulkan drivers..."
    pacman -S --noconfirm vulkan-radeon libva-mesa-driver 2>/dev/null || true
fi

# Detect CPU vendor
CPU_VENDOR=""
if grep -qi "intel" /proc/cpuinfo; then
    CPU_VENDOR="intel"
elif grep -qi "amd" /proc/cpuinfo; then
    CPU_VENDOR="amd"
fi

info "Detected CPU: ${CPU_VENDOR:-unknown}"

if [[ "$CPU_VENDOR" == "intel" ]]; then
    pacman -S --noconfirm intel-ucode 2>/dev/null || true
elif [[ "$CPU_VENDOR" == "amd" ]]; then
    pacman -S --noconfirm amd-ucode 2>/dev/null || true
fi

# Detect virtual machine
if systemd-detect-virt -q; then
    info "Running in a virtual machine"
    VIRT_TYPE=$(systemd-detect-virt)
    if [[ "$VIRT_TYPE" == "vmware" ]]; then
        pacman -S --noconfirm open-vm-tools 2>/dev/null || true
    elif [[ "$VIRT_TYPE" == "oracle" ]]; then
        pacman -S --noconfirm virtualbox-guest-utils 2>/dev/null || true
    fi
fi

info "Hardware detection complete"
