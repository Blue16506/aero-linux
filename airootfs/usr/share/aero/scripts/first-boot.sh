#!/bin/bash
set -euo pipefail

# Aero Linux - First Boot Setup
# Runs once after installation to finalize configuration

trap 'echo "[FIRSTBOOT] FAILED at line $LINENO: $BASH_COMMAND"' ERR

AERO_LOG="/var/log/aero-firstboot.log"
AERO_PACKAGES="/usr/share/aero/packages"
AERO_SCRIPTS="/usr/share/aero/scripts"

exec > >(tee -a "$AERO_LOG") 2>&1

# ---------------------------------------------------------------------------
#  Utility functions
# ---------------------------------------------------------------------------

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m  OK\033[0m\n"; }

# ---------------------------------------------------------------------------
#  Snapper initialization (idempotent, deferred from installer)
# ---------------------------------------------------------------------------

init_snapper() {
    if ! snapper list-configs 2>/dev/null | grep -q '^root'; then
        echo "[FIRSTBOOT] Initializing root Snapper config..."
        snapper -c root create-config /
        echo "[FIRSTBOOT] Root config verification:"
        snapper list-configs 2>/dev/null
        ls -la /.snapshots 2>/dev/null || true
        if ! snapper list-configs 2>/dev/null | grep -q '^root'; then
            echo "[FIRSTBOOT] Root Snapper initialization failed."
        fi
    else
        echo "[FIRSTBOOT] Root config already exists."
    fi

    if ! snapper list-configs 2>/dev/null | grep -q '^home'; then
        echo "[FIRSTBOOT] Initializing home Snapper config..."
        snapper -c home create-config /home
        echo "[FIRSTBOOT] Home config verification:"
        snapper list-configs 2>/dev/null
        ls -la /home/.snapshots 2>/dev/null || true
        if ! snapper list-configs 2>/dev/null | grep -q '^home'; then
            echo "[FIRSTBOOT] Home Snapper initialization failed."
        fi
    else
        echo "[FIRSTBOOT] Home config already exists."
    fi

    # Guarded overlay: only copy templates if create-config succeeded
    [[ -f /etc/snapper/configs/root ]] &&
        cp -f /usr/share/aero/configs/snapper/root /etc/snapper/configs/root
    [[ -f /etc/snapper/configs/home ]] &&
        cp -f /usr/share/aero/configs/snapper/home /etc/snapper/configs/home

    # Create initial snapshots (idempotent — checks by description)
    echo "[FIRSTBOOT] Creating initial snapshots..."
    if ! snapper -c root list | grep -q 'Initial Aero installation'; then
        snapper -c root create --description "Initial Aero installation" --cleanup number
    fi
    if ! snapper -c home list | grep -q 'Initial Home snapshot'; then
        snapper -c home create --description "Initial Home snapshot" --cleanup number
    fi

    echo "[FIRSTBOOT] Snapper initialization complete."
}

# ---------------------------------------------------------------------------
#  Phase 0 – Preflight
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 0 – Preflight"

printf "\033[1;36m"
printf "    █████╗ ███████╗██████╗  ██████╗ \n"
printf "   ██╔══██╗██╔════╝██╔══██╗██╔═══██╗\n"
printf "   ███████║█████╗  ██████╔╝██║   ██║\n"
printf "   ██╔══██║██╔══╝  ██╔══██╗██║   ██║\n"
printf "   ██║  ██║███████╗██║  ██║╚██████╔╝\n"
printf "   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ \n"
printf "\033[0m\n"
info "Aero Linux First Boot Setup"
info "Starting at $(date)"

[[ $EUID -eq 0 ]] || error "first-boot must run as root"

[[ -f /etc/aero-installed ]] || error "Not an Aero Linux installation"

# Read install config
if [[ -f /etc/aero-install.conf ]]; then
    source /etc/aero-install.conf
else
    USERNAME=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {print $1; exit}')
    : "${USERNAME:=user}"
    HOSTNAME=$(hostname)
fi

USER_HOME="/home/$USERNAME"
[[ -d "$USER_HOME" ]] || error "User home directory $USER_HOME not found"

info "Setting up for user: $USERNAME"

# ---------------------------------------------------------------------------
#  Phase 1 – Snapper initialization (local filesystem, no network needed)
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 1 – Snapper initialization"

echo "[FIRSTBOOT] Initializing Snapper..."
if command -v snapper &>/dev/null; then
    init_snapper
    ok
else
    warn "snapper not installed"
fi

# ---------------------------------------------------------------------------
#  Phase 2 – Network wait
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 2 – Network wait"

info "Waiting for network..."
for i in $(seq 30); do
    ping -c 1 archlinux.org &>/dev/null && { ok; break; }
    [[ $i -eq 30 ]] && warn "Network not available – skipping AUR packages"
    sleep 2
done

# ---------------------------------------------------------------------------
#  Phase 3 – AUR packages
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 3 – AUR packages"

if ping -c 1 archlinux.org &>/dev/null && [[ -f "$AERO_PACKAGES/aur.packages" ]]; then
    info "Installing AUR packages..."
    mapfile -t aur_pkgs < <(grep -v '^#' "$AERO_PACKAGES/aur.packages" | grep -v '^$')
    if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
        sudo -u "$USERNAME" yay -S --needed --noconfirm "${aur_pkgs[@]}" 2>/dev/null || \
            warn "Some AUR packages failed to install"
        ok
    fi
fi

# ---------------------------------------------------------------------------
#  Phase 4 – XDG user directories
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 4 – XDG user directories"

if command -v xdg-user-dirs-update &>/dev/null; then
    info "Creating XDG user directories..."
    sudo -u "$USERNAME" xdg-user-dirs-update 2>/dev/null || true
    ok
fi

# ---------------------------------------------------------------------------
# Phase 5 – Hardware detection
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 5 – Hardware detection"

if [[ -x "$AERO_SCRIPTS/hardware-detect.sh" ]]; then
    info "Running hardware detection..."
    "$AERO_SCRIPTS/hardware-detect.sh" || warn "Hardware detection encountered issues"
    ok
fi

# ---------------------------------------------------------------------------
#  Phase 6 – Branding
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 6 – Branding"

info "Applying branding..."

# Default wallpaper
AERO_WALLPAPER="/usr/share/backgrounds/aero/default.jpg"
if [[ -f "$AERO_WALLPAPER" ]]; then
    mkdir -p "$USER_HOME/.config/aero" 2>/dev/null || true
    ln -sf "$AERO_WALLPAPER" "$USER_HOME/.config/aero/wallpaper" 2>/dev/null || true
    chown -h "$USERNAME":"$USERNAME" "$USER_HOME/.config/aero/wallpaper" 2>/dev/null || true
fi

# Deploy hyprpaper config
AERO_HYPRPAPER_CONF="/usr/share/aero/configs/hypr/hyprpaper.conf"
if [[ -f "$AERO_HYPRPAPER_CONF" ]]; then
    mkdir -p "$USER_HOME/.config/hypr" 2>/dev/null || true
    cp "$AERO_HYPRPAPER_CONF" "$USER_HOME/.config/hypr/hyprpaper.conf" 2>/dev/null || true
    chown "$USERNAME":"$USERNAME" "$USER_HOME/.config/hypr/hyprpaper.conf" 2>/dev/null || true
fi

# Apply default theme if available
# Use -H to ensure $HOME is set to the user's home (not root's)
if [[ -x /usr/local/bin/aero-theme ]]; then
    sudo -Hu "$USERNAME" aero-theme apply catppuccin 2>/dev/null || true
fi

ok

# ---------------------------------------------------------------------------
#  Phase 7 – Cleanup
# ---------------------------------------------------------------------------

echo "[FIRSTBOOT] Entering Phase 7 - Cleanup"

info "Cleaning up first-boot service..."

touch /etc/aero-firstboot-complete

systemctl disable aero-firstboot.service 2>/dev/null || true

printf "\n"
printf "\033[1;32mAero Linux first boot setup complete.\033[0m\n"
printf "Log: %s\n" "$AERO_LOG"
printf "\n"

info "Finished at $(date)"

exit 0
