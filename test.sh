#!/bin/bash
set -euo pipefail

# Aero Linux - QEMU Test Script
# Tests the ISO in a virtual machine

AERO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-discover newest ISO — resilient to date/version changes
ISO="$(ls -t "$AERO_DIR"/out/*.iso 2>/dev/null | head -n1)"
if [[ -z "$ISO" ]]; then
    echo "[ERROR] No ISO found in out/. Run build.sh first."
    exit 1
fi
TEST_DISK="/tmp/aero-test-disk.qcow2"
OVMF_VARS="/tmp/OVMF_VARS.4m.fd"
MEM="4G"
CPUS="2"

# Colors
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

info()  { printf "${GREEN}[INFO]${NC}  %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$*"; exit 1; }

usage() {
    cat <<EOF
Usage: $0 <mode> [options]

Modes:
  live              Boot ISO in UEFI mode (test live environment)
  live-bios         Boot ISO in BIOS mode
  install           Install using existing test disk if present
  install --clean   Delete qcow2 and OVMF variables, then do a fresh install
  boot              Boot the installed test disk
  cleanup           Remove the test disk
  help              Show this help
EOF
    exit 0
}

check_deps() {
    command -v qemu-system-x86_64 >/dev/null 2>&1 || error "qemu-system-x86_64 not found. Install: sudo pacman -S qemu-desktop"
    OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
    [[ -f "$OVMF_CODE" ]] || error "UEFI firmware not found. Install: sudo pacman -S edk2-ovmf"
    [[ -f "$OVMF_VARS" ]] || cp "/usr/share/edk2/x64/OVMF_VARS.4m.fd" "$OVMF_VARS"
    UEFI_ARGS="-drive if=pflash,format=raw,readonly=on,file=$OVMF_CODE -drive if=pflash,format=raw,file=$OVMF_VARS"
    [[ -f "$ISO" ]] || error "ISO not found at $ISO. Was it deleted?"
}

[[ $# -lt 1 ]] && usage
MODE="$1"

case "$MODE" in
    live)
        check_deps
        info "Booting ISO in UEFI mode..."
        qemu-system-x86_64 -enable-kvm -m "$MEM" -smp "$CPUS" -cpu host \
            -cdrom "$ISO" \
            $UEFI_ARGS \
            -nic user
        ;;

    live-bios)
        check_deps
        info "Booting ISO in BIOS mode..."
        qemu-system-x86_64 -enable-kvm -m "$MEM" -smp "$CPUS" -cpu host \
            -cdrom "$ISO" \
            -nic user
        ;;

    install)
        CLEAN="${2:-}"
        if [[ "$CLEAN" == "--clean" ]]; then
            info "Clean test requested."
            rm -f "$TEST_DISK" "$OVMF_VARS"
            info "Removed test disk and OVMF variables."
        elif [[ -n "$CLEAN" ]]; then
            error "Unknown option: $CLEAN. Use 'install --clean' for a fresh install."
        fi
        check_deps
        if [[ ! -f "$TEST_DISK" ]]; then
            info "Creating test disk at $TEST_DISK (20G)..."
            qemu-img create -f qcow2 "$TEST_DISK" 20G
        else
            warn "Existing test disk found:"
            warn "  $TEST_DISK"
            warn ""
            warn "Tip:"
            warn "  bash test.sh install --clean"
            warn "      Start from a completely fresh installation."
        fi
        info "Booting ISO with test disk for installation..."
        qemu-system-x86_64 -enable-kvm -m "$MEM" -smp "$CPUS" -cpu host \
            -cdrom "$ISO" \
            -drive file="$TEST_DISK",format=qcow2,if=virtio \
            $UEFI_ARGS \
            -nic user
        ;;

    boot)
        check_deps
        [[ -f "$TEST_DISK" ]] || error "No test disk found at $TEST_DISK. Run 'install' mode first."
        info "Booting installed system from test disk..."
        qemu-system-x86_64 -enable-kvm -m "$MEM" -smp "$CPUS" -cpu host \
            -drive file="$TEST_DISK",format=qcow2,if=virtio \
            $UEFI_ARGS \
            -nic user
        ;;

    cleanup)
        if [[ -f "$TEST_DISK" ]]; then
            info "Removing test disk..."
            rm -f "$TEST_DISK"
            info "Done"
        else
            info "No test disk to remove"
        fi
        ;;

    *)
        usage
        ;;
esac
