#!/bin/bash
set -euo pipefail

# Aero Linux - First Boot Setup
# Runs once after installation to finalize configuration

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
#  Phase 0 – Preflight
# ---------------------------------------------------------------------------

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
#  Phase 1 – Network wait
# ---------------------------------------------------------------------------

info "Waiting for network..."
for i in $(seq 30); do
    ping -c 1 archlinux.org &>/dev/null && { ok; break; }
    [[ $i -eq 30 ]] && warn "Network not available – skipping AUR packages"
    sleep 2
done

# ---------------------------------------------------------------------------
#  Phase 2 – Snapper configuration
# ---------------------------------------------------------------------------

info "Configuring Snapper..."
if command -v snapper &>/dev/null; then
    if ! [[ -f /etc/snapper/configs/root ]]; then
        snapper -c root create-config / && \
        cp /usr/share/aero/configs/snapper/root /etc/snapper/configs/root && \
        info "Root snapper config created" || \
        warn "Failed to create root snapper config"
    else
        info "Root snapper config already exists"
    fi

    if ! [[ -f /etc/snapper/configs/home ]]; then
        snapper -c home create-config /home && \
        cp /usr/share/aero/configs/snapper/home /etc/snapper/configs/home && \
        info "Home snapper config created" || \
        warn "Failed to create home snapper config"
    else
        info "Home snapper config already exists"
    fi

    if [[ -f /etc/snapper/configs/root ]] && [[ -f /etc/snapper/configs/home ]]; then
        systemctl enable snapper-boot 2>/dev/null || warn "Failed to enable snapper-boot"
    fi

    ok
else
    warn "snapper not installed"
fi

# ---------------------------------------------------------------------------
#  Phase 3 – AUR packages
# ---------------------------------------------------------------------------

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
#  Phase 4 – Snapper initial snapshots
# ---------------------------------------------------------------------------

info "Creating initial snapshots..."
if command -v snapper &>/dev/null; then
    snapper -c root create --description "initial-install" --cleanup number 2>/dev/null || true
    snapper -c home create --description "initial-install" --cleanup number 2>/dev/null || true
    snapper -c root set-config TIMELINE_CREATE=yes 2>/dev/null || true
    snapper -c home set-config TIMELINE_CREATE=yes 2>/dev/null || true
    ok
fi

# ---------------------------------------------------------------------------
#  Phase 5 – XDG user directories
# ---------------------------------------------------------------------------

if command -v xdg-user-dirs-update &>/dev/null; then
    info "Creating XDG user directories..."
    sudo -u "$USERNAME" xdg-user-dirs-update 2>/dev/null || true
    ok
fi

# ---------------------------------------------------------------------------
#  Phase 6 – Hardware detection
# ---------------------------------------------------------------------------

if [[ -x "$AERO_SCRIPTS/hardware-detect.sh" ]]; then
    info "Running hardware detection..."
    "$AERO_SCRIPTS/hardware-detect.sh" || warn "Hardware detection encountered issues"
    ok
fi

# ---------------------------------------------------------------------------
#  Phase 7 – Branding
# ---------------------------------------------------------------------------

info "Applying branding..."

# Default wallpaper
AERO_WALLPAPER="/usr/share/backgrounds/aero/default.jpg"
if [[ -f "$AERO_WALLPAPER" ]]; then
    mkdir -p "$USER_HOME/.config/aero"
    ln -sf "$AERO_WALLPAPER" "$USER_HOME/.config/aero/wallpaper" 2>/dev/null || true
    chown -h "$USERNAME":"$USERNAME" "$USER_HOME/.config/aero/wallpaper" 2>/dev/null || true
fi

# Apply default theme if available
# Use -H to ensure $HOME is set to the user's home (not root's)
if [[ -x /usr/local/bin/aero-theme ]]; then
    sudo -Hu "$USERNAME" aero-theme apply catppuccin 2>/dev/null || true
fi

ok

# ---------------------------------------------------------------------------
#  Phase 8 – Cleanup
# ---------------------------------------------------------------------------

info "Cleaning up first-boot service..."

systemctl disable aero-firstboot 2>/dev/null || true
systemctl stop aero-firstboot 2>/dev/null || true
rm -f /etc/systemd/system/aero-firstboot.service
rm -f /etc/systemd/system/multi-user.target.wants/aero-firstboot.service

# Leave marker that first-boot has completed
touch /etc/aero-firstboot-complete

printf "\n"
printf "\033[1;32m  Aero Linux first boot setup complete.\033[0m\n"
printf "  Log: %s\n" "$AERO_LOG"
printf "\n"
info "Finished at $(date)"
