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
│   │   ├── os-release                 # Live ISO identification
│   │   ├── pacman.d/mirrorlist        # Package mirrors
│   │   ├── pam.d/greetd               # PAM config for greetd
│   │   ├── snapper/config-templates/  # root and home snapper configs
│   │   ├── sudoers.d/aero-installer   # Passwordless sudo for live env
│   │   ├── systemd/system/
│   │   │   ├── aero-firstboot.service # First-boot setup service
│   │   │   └── snapper-boot.service   # Boot-time snapshot service
│   │   └── zsh/zshenv                 # Global zsh environment
│   ├── root/                          # Live environment root
│   │   ├── .automated_script.sh       # Auto-launches installer on boot
│   │   ├── .config/starship.toml      # Root prompt theme
│   │   ├── .zshrc                     # Live env shell config
│   │   └── customize_airootfs.sh      # archiso post-build customization
│   └── usr/
│       ├── local/bin/
│       │   ├── aero-greeter           # Greeter wrapper for tuigreet
│       │   ├── aero-install           # Main interactive installer
│       │   └── aero-theme             # Theme switching CLI
│       └── share/aero/
│           ├── configs/
│           │   ├── ghostty/config     # Terminal config
│           │   ├── hypr/              # Modular Hyprland configs
│           │   ├── mako/config        # Notification daemon
│           │   ├── snapper/           # Snapper policies
│           │   ├── walker/            # Application launcher (config.toml + theme)
│           │   ├── waybar/            # Status bar configs
│           │   ├── wlogout/           # Power menu configs
│           │   └── zsh/               # Modular zsh configs
│           ├── packages/
│           │   ├── aur.packages       # AUR packages for first-boot
│           │   └── desktop.packages   # Extra desktop packages
│           ├── scripts/
│           │   ├── first-boot.sh      # Post-install setup
│           │   └── hardware-detect.sh # GPU/CPU detection
│           └── themes/                # Theme definitions
├── efiboot/                           # archiso UEFI boot files
├── limine/                            # Limine bootloader binaries
├── out/                               # ISO build output
├── syslinux/                          # archiso BIOS boot files
├── packages.x86_64                    # Packages included in ISO
├── profiledef.sh                      # archiso profile definition
├── pacman.conf                        # Build-time pacman config
├── build.sh                           # ISO build wrapper
├── test.sh                            # QEMU test helper
└── TESTING.md                         # Test documentation
```

> **Note:** `syslinux/` and `efiboot/` are standard archiso boot directories for the live ISO.
> Limine is installed as the bootloader on the *target system* during installation.

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
├── autostart.conf     # Startup applications
└── windowrules.conf   # Window rules per application
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

Comprises Hyprland (window manager), Waybar (status bar), Ghostty (terminal), greetd+tuigreet (display manager), mako (notifications), walker (application launcher), wlogout (power menu), hyprlock+swaybg+lockscreen, and hypridle (idle).

## Coding Standards

- Shell scripts use `bash` with `set -euo pipefail`
- Inputs are validated before use
- Failures are handled gracefully with meaningful error messages
- Status messages printed inline for user visibility
- Important operations logged to install log
- Scripts are idempotent whenever practical
- No unnecessary dependencies
- Readability and maintainability preferred over cleverness

## Files Created (43 files)

| Category | File | Purpose |
|----------|------|---------|
| **ISO Profile** | `packages.x86_64` | ISO package list with Hyprland, Ghostty, greetd, zsh, etc. |
| | `profiledef.sh` | archiso profile metadata and permissions |
| | `pacman.conf` | Build-time pacman configuration |
| | `build.sh` | ISO build wrapper |
| **Live Environment** | `airootfs/root/.zshrc` | Live env shell config |
| | `airootfs/root/.automated_script.sh` | Auto-launch installer on boot |
| | `airootfs/root/.config/starship.toml` | Root prompt theme |
| | `airootfs/root/customize_airootfs.sh` | archiso post-build customization |
| **System Config** | `airootfs/etc/greetd/config.toml` | greetd TUI greeter config |
| | `airootfs/etc/pam.d/greetd` | PAM config for greetd |
| | `airootfs/etc/limine.conf` | Bootloader configuration template |
| | `airootfs/etc/mkinitcpio.conf` | Initramfs with btrfs + LUKS hooks |
| | `airootfs/etc/pacman.d/mirrorlist` | Package mirrors |
| | `airootfs/etc/os-release` | Live ISO identification |
| | `airootfs/etc/sudoers.d/aero-installer` | Live environment sudo rules |
| | `airootfs/etc/zsh/zshenv` | Global zsh environment variables |
| **Snapper Configs** | `airootfs/etc/snapper/config-templates/root` | Root snapper policy (ISO) |
| | `airootfs/etc/snapper/config-templates/home` | Home snapper policy (ISO) |
| | `airootfs/usr/share/aero/configs/snapper/root` | Root snapper policy (installed) |
| | `airootfs/usr/share/aero/configs/snapper/home` | Home snapper policy (installed) |
| **Systemd Services** | `airootfs/etc/systemd/system/aero-firstboot.service` | First-boot setup service |
| | `airootfs/etc/systemd/system/snapper-boot.service` | Boot-time snapshot service |
| **Installer** | `airootfs/usr/local/bin/aero-install` | Main interactive installer script |
| | `airootfs/usr/local/bin/aero-greeter` | Greeter wrapper for tuigreet |
| **First Boot** | `airootfs/usr/share/aero/scripts/first-boot.sh` | First boot setup script |
| | `airootfs/usr/share/aero/scripts/hardware-detect.sh` | GPU/CPU detection script |
| **Packages** | `airootfs/usr/share/aero/packages/aur.packages` | AUR packages list |
| | `airootfs/usr/share/aero/packages/desktop.packages` | Desktop extras list |
| **Desktop Configs** | `airootfs/usr/share/aero/configs/hypr/*` (7 files) | Modular Hyprland configs |
| | `airootfs/usr/share/aero/configs/waybar/*` (2 files) | Waybar config + style |
| | `airootfs/usr/share/aero/configs/ghostty/config` | Ghostty terminal config |
| | `airootfs/usr/share/aero/configs/zsh/*` (6 files) | Modular zsh configs |
| | `airootfs/usr/share/aero/configs/mako/config` | Notification daemon config |
| | `airootfs/usr/share/aero/configs/wlogout/*` (2 files) | Power menu config |
| | `airootfs/usr/share/aero/configs/walker/*` | Application launcher config + theme |
| **Themes** | `airootfs/usr/local/bin/aero-theme` | Theme switching CLI |
| | `airootfs/usr/share/aero/themes/catppuccin/*` | Catppuccin Mocha theme |
| **Testing** | `test.sh` | QEMU test script |
| | `TESTING.md` | Test documentation |

## Definition of Success

- `mkarchiso` builds successfully
- Produces a bootable ISO that boots to greetd+tuigreet
- Interactive installer completes without errors
- Installed system boots directly into Hyprland with Waybar
- Snapper snapshots work for root and home
- System is clean, maintainable, and well-documented
