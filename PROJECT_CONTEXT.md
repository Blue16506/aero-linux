# Aero Linux

## Project Overview

A custom Arch Linux distribution focused on simplicity, reliability, performance, and a polished Hyprland desktop experience. Builds as a bootable ArchISO with an interactive installer and minimal post-installation setup.

## Core Goals

1. Easy installation via interactive TUI installer
2. Modern Wayland desktop using Hyprland
3. Reliable rollback with Btrfs + Snapper
4. Fast boot using Limine bootloader
5. Clean, modular configuration files
6. Consistent visual design across the system
7. Easy maintenance and extension
8. Reproducible ISO builds

## Technology Stack

| Component | Choice |
|-----------|--------|
| Base | Arch Linux |
| ISO Builder | archiso |
| Bootloader | Limine (UEFI + BIOS) |
| Filesystem | Btrfs with subvolumes |
| Snapshots | Snapper |
| Window Manager | Hyprland |
| Terminal | Ghostty |
| Status Bar | Waybar |
| Display Manager | greetd + tuigreet |
| Shell | zsh |
| Network | NetworkManager |
| Audio | PipeWire |
| Bluetooth | BlueZ |

## Directory Structure

```
aero/
├── airootfs/                          # Overlay filesystem for ISO
│   ├── etc/
│   │   ├── greetd/config.toml         # greetd + tuigreet config
│   │   ├── limine.conf                # Limine bootloader template
│   │   ├── mkinitcpio.conf            # Initramfs with btrfs hooks
│   │   ├── pacman.d/mirrorlist        # Package mirrors
│   │   ├── snapper/config-templates/  # root and home snapper configs
│   │   ├── sudoers.d/aero-installer   # Passwordless sudo for live env
│   │   ├── systemd/system/
│   │   │   ├── aero-firstboot.service # First-boot setup service
│   │   │   └── snapper-boot.service   # Boot-time snapshot service
│   │   └── zsh/zshenv                 # Global zsh environment
│   └── root/                          # Live environment root
├── packages.x86_64                    # Packages included in ISO
├── profiledef.sh                      # archiso profile definition
└── pacman.conf                        # Build-time pacman config
```

## Btrfs Subvolume Layout

```
/ (btrfs top-level)
├── @                  # Root subvolume (snapshotted, mounted at /)
├── @home              # Home subvolume (snapshotted, mounted at /home)
├── @cache             # Pacman cache (excluded from snapshots)
├── @log               # Log files (excluded from snapshots)
└── @snapshots         # Snapper snapshots directory
```

## Installer Requirements (`aero-install`)

The installer script must:

1. Detect UEFI vs BIOS
2. Present interactive prompts: keyboard layout, disk selection, hostname, username, password
3. Partition disks safely with user confirmation
4. Create Btrfs subvolumes with the layout above
5. Pacstrap the base system plus ISO package list
6. Generate fstab
7. Configure system: locale, timezone, hostname, hosts
8. Set root password, create user, configure sudo
9. Install Limine bootloader (UEFI + BIOS)
10. Generate initramfs
11. Enable services: greetd, NetworkManager, pipewire, bluetooth
12. Install configuration files to user's home
13. Enable first-boot service

## First Boot Requirements (`first-boot.sh`)

The first-boot script must:

1. Run automatically once via systemd service
2. Detect presence of `aero-firstboot.service` and `/etc/aero-installed`
3. Initialize Snapper for root and home
4. Install AUR packages from aur.packages list
5. Apply hardware-specific configurations
6. Create XDG user directories
7. Remove itself after completion
8. Leave `/etc/aero-installed` marker

## Hyprland Architecture

Configuration is modular:

```
hypr/
├── hyprland.conf      # Main config, sources all others
├── monitors.conf      # Monitor layout and resolution
├── input.conf         # Keyboard, touchpad, mouse
├── binds.conf         # Keybindings
├── appearance.conf    # Animations, gaps, borders, colors
└── autostart.conf     # Startup applications
```

## Theme System

Configuration files shared by Hyprland, Waybar, Ghostty, etc. will use a single source of truth for colors. Theme structure:

```
themes/<theme-name>/
├── colors.toml        # Color palette (tomed by aero-theme)
├── hyprland.conf      # Hyprland appearance overrides
├── waybar.css         # Waybar style overrides
├── ghostty.conf       # Ghostty color overrides
├── starship.toml      # Prompt style overrides
└── wallpaper.jpg      # Desktop wallpaper
```

## Desktop Environment

Comprises Hyprland (window manager), Waybar (status bar), Ghostty (terminal), greetd+tuigreet (display manager), mako (notifications), fuzzel/rofi-wayland (launcher), wlogout (power menu), hyprlock+swaybg+lockscreen, and hypridle (idle).

## Coding Standards

- Shell scripts use `bash` with `set -euo pipefail`
- Inputs are validated before use
- Failures are handled gracefully with meaningful error messages
- Status messages printed inline for user visibility
- Important operations logged to install log
- Scripts are idempotent whenever practical
- No unnecessary dependencies
- Readability and maintainability preferred over cleverness

## Files Already Created (13 files)

| File | Purpose |
|------|---------|
| `aero/packages.x86_64` | ISO package list with Hyprland, Ghostty, greetd, zsh, etc. |
| `aero/profiledef.sh` | archiso profile metadata and permissions |
| `aero/pacman.conf` | Build-time pacman configuration |
| `aero/airootfs/etc/greetd/config.toml` | greetd TUI greeter config |
| `aero/airootfs/etc/limine.conf` | Bootloader configuration template |
| `aero/airootfs/etc/mkinitcpio.conf` | Initramfs with btrfs + LUKS hooks |
| `aero/airootfs/etc/pacman.d/mirrorlist` | Package mirrors |
| `aero/airootfs/etc/snapper/config-templates/root` | Root snapper policy |
| `aero/airootfs/etc/snapper/config-templates/home` | Home snapper policy |
| `aero/airootfs/etc/sudoers.d/aero-installer` | Live environment sudo rules |
| `aero/airootfs/etc/systemd/system/aero-firstboot.service` | First-boot systemd service |
| `aero/airootfs/etc/systemd/system/snapper-boot.service` | Boot-time snapshot service |
| `aero/airootfs/etc/zsh/zshenv` | Global zsh environment variables |

## Files Not Yet Created

| File | Priority |
|------|----------|
| `aero/airootfs/usr/local/bin/aero-install` | HIGH - Main installer script |
| `aero/airootfs/usr/share/aero/scripts/first-boot.sh` | HIGH - First boot setup |
| `aero/airootfs/usr/share/aero/scripts/hardware-detect.sh` | MEDIUM - Hardware detection |
| `aero/airootfs/usr/share/aero/packages/aur.packages` | MEDIUM - AUR package list |
| `aero/airootfs/etc/pam.d/greetd` | HIGH - PAM config for greetd |
| `aero/airootfs/root/.zshrc` | MEDIUM - Live env shell config |
| `aero/build.sh` | HIGH - ISO build wrapper |
| `aero/limine/*` | HIGH - Limine bootloader binaries |
| `aero/airootfs/usr/share/aero/configs/hypr/*` | HIGH - Hyprland modular configs |
| `aero/airootfs/usr/share/aero/configs/waybar/*` | HIGH - Waybar config |
| `aero/airootfs/usr/share/aero/configs/ghostty/*` | HIGH - Ghostty config |
| `aero/airootfs/usr/share/aero/configs/zsh/*` | HIGH - User zsh config |
| `aero/airootfs/usr/share/aero/configs/mako/*` | MEDIUM - Notification config |
| `aero/airootfs/usr/share/aero/configs/wlogout/*` | MEDIUM - Power menu |
| `aero/airootfs/usr/share/aero/themes/*` | LOW - Theme definitions |
| `aero/airootfs/root/customize_airootfs.sh` | HIGH - archiso post-build script |

## Definition of Success

- `mkarchiso` builds successfully
- Produces a bootable ISO that boots to greetd+tuigreet
- Interactive installer completes without errors
- Installed system boots directly into Hyprland with Waybar
- Snapper snapshots work for root and home
- System is clean, maintainable, and well-documented
