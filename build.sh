#!/bin/bash
set -euo pipefail

# Aero Linux - ISO Build Script
# Builds the Aero Linux live ISO using archiso

AERO_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$AERO_DIR/out"
WORK_DIR="/tmp/aero-build-$$"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

cleanup() {
    [[ -d "$WORK_DIR" ]] && sudo rm -rf "$WORK_DIR" 2>/dev/null || true
}
trap cleanup EXIT

printf "${CYAN}"
printf "    █████╗ ███████╗██████╗  ██████╗ \n"
printf "   ██╔══██╗██╔════╝██╔══██╗██╔═══██╗\n"
printf "   ███████║█████╗  ██████╔╝██║   ██║\n"
printf "   ██╔══██║██╔══╝  ██╔══██╗██║   ██║\n"
printf "   ██║  ██║███████╗██║  ██║╚██████╔╝\n"
printf "   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ \n"
printf "${NC}\n"
printf "  Aero Linux ISO Builder\n"
printf "\n"

info() { printf "${GREEN}[INFO]${NC}  %s\n" "$*"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$*"; exit 1; }

# Prerequisites check
command -v mkarchiso >/dev/null 2>&1 || error "mkarchiso not found – install archiso: sudo pacman -S archiso"
command -v limine-install >/dev/null 2>&1 || error "limine not found – install limine: sudo pacman -S limine"

[[ -f "$AERO_DIR/profiledef.sh" ]] || error "profiledef.sh not found – run this script from the profile directory"

# Check if running as root (mkarchiso requires root for some operations)
[[ $EUID -eq 0 ]] || error "Build script must be run as root"

# Clean previous builds
if [[ -d "$OUT_DIR" ]]; then
    info "Cleaning previous build output..."
    rm -rf "$OUT_DIR"
fi

mkdir -p "$OUT_DIR"

# Build the ISO
info "Starting ISO build..."
info "Profile: $AERO_DIR"
info "Work dir: $WORK_DIR"
info "Output: $OUT_DIR"
printf "\n"

sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$AERO_DIR"

# Check result
ISO_FILE=$(ls "$OUT_DIR"/*.iso 2>/dev/null || true)
if [[ -n "$ISO_FILE" ]]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    printf "\n"
    printf "${GREEN}Build successful!${NC}\n"
    printf "  ISO: %s\n" "$ISO_FILE"
    printf "  Size: %s\n" "$ISO_SIZE"
    printf "\n"
    printf "  Test with QEMU:\n"
    printf "    qemu-system-x86_64 -enable-kvm -m 4G -cpu host -drive file=%s,format=raw,if=virtio -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd\n" "$ISO_FILE"
    printf "\n"
else
    error "Build failed – ISO not found"
fi
