# Aero Linux

## Project Overview

A custom Arch Linux distribution focused on simplicity, reliability, performance, and a polished Hyprland desktop experience. Builds as a bootable ArchISO with an interactive TUI installer and minimal post-installation setup.

**Status:** Pre-alpha — Live Environment Validation Passed. ISO builds, UEFI boots, Hyprland desktop with Waybar/Ghostty/Neovim/Zsh fully functional. Now focused on installer and installed-system validation.

## Core Goals

1. Easy installation via interactive TUI installer
2. Modern Wayland desktop using Hyprland
3. Reliable rollback with Btrfs + Snapper
4. Fast boot using Limine bootloader
5. Clean, modular configuration files
6. Consistent visual design across the system
7. Easy maintenance and extension
8. Reproducible ISO builds
9. Bash-first philosophy — no Python tooling, minimal dependencies

## Technology Stack

| Component | Choice |
|-----------|--------|
| Base | Arch Linux |
| ISO Builder | archiso |
| Bootloader (ISO) | systemd-boot (UEFI) / syslinux (BIOS) |
| Bootloader (installed) | Limine (UEFI + BIOS) |
| Filesystem | Btrfs with subvolumes |
| Snapshots | Snapper |
| Window Manager | Hyprland |
| Terminal | Ghostty |
| Status Bar | Waybar |
| Application Launcher | walker (installed post-boot via AUR) |
| Display Manager | greetd + tuigreet |
| Shell | zsh |
| Network | NetworkManager |
| Audio | PipeWire |
| Notifications | mako |
| Power Menu | wlogout |
| Screen Lock | hyprlock |
| Idle Daemon | hypridle |

## Directory Structure

```
aero/
├── .gitignore
├── PROJECT_CONTEXT.md              # This file
├── PROJECT_AUDIT.md                # Audit report
├── README.md                       # Project README
├── TESTING.md                      # Manual test checklist
├── TODO.md                         # Task tracking
├── build.sh                        # ISO build wrapper
├── test.sh                         # QEMU test helper
├── packages.x86_64                 # Packages in ISO
├── pacman.conf                     # Build-time pacman config
├── profiledef.sh                   # archiso profile definition
├── efiboot/                        # archiso UEFI boot files
│   ├── loader/loader.conf
│   └── loader/entries/01-aero-linux.conf
├── syslinux/                       # archiso BIOS boot files
│   ├── syslinux.cfg
│   ├── archiso_head.cfg
│   ├── archiso_sys.cfg
│   ├── archiso_sys-linux.cfg
│   ├── archiso_tail.cfg
│   └── splash.png
├── limine/                         # Limine bootloader binaries
│   ├── limine-bios.sys
│   ├── limine-uefi-cd.bin
│   └── BOOTX64.EFI
├── airootfs/                       # Overlay filesystem for ISO
│   ├── etc/
│   │   ├── greetd/config.toml
│   │   ├── limine.conf
│   │   ├── mkinitcpio.conf
│   │   ├── os-release
│   │   ├── pacman.d/mirrorlist
│   │   ├── pam.d/greetd
│   │   ├── snapper/config-templates/root
│   │   ├── snapper/config-templates/home
│   │   ├── sudoers.d/aero-installer
│   │   ├── systemd/system/
│   │   │   ├── aero-firstboot.service
│   │   │   └── snapper-boot.service
│   │   └── zsh/zshenv
│   ├── root/
│   │   ├── .automated_script.sh
│   │   ├── .config/starship.toml
│   │   ├── .zshrc
│   │   └── customize_airootfs.sh
│   └── usr/
│       ├── local/bin/
│       │   ├── aero-greeter
│       │   ├── aero-install
│       │   └── aero-theme
│       └── share/
│           ├── backgrounds/aero/default.jpg
│           └── aero/
│               ├── configs/
│               │   ├── ghostty/config
│               │   ├── hypr/
│               │   ├── mako/config
│               │   ├── snapper/root
│               │   ├── snapper/home
│               │   ├── walker/config.toml
│               │   ├── walker/themes/aero/style.css
│               │   ├── waybar/config.jsonc
│               │   ├── waybar/style.css
│               │   ├── wlogout/layout.json
│               │   ├── wlogout/style.css
│               │   └── zsh/
│               ├── packages/
│               │   ├── aur.packages
│               │   └── desktop.packages
│               ├── scripts/
│               │   ├── first-boot.sh
│               │   └── hardware-detect.sh
│               └── themes/
│                   └── catppuccin/
│                       ├── colors.toml
│                       └── wallpaper.jpg
└── out/                            # ISO build output
```

> `syslinux/` and `efiboot/` are standard archiso boot directories for the live ISO only.
> Limine is installed as the bootloader on the installed system during `aero-install`.

## Btrfs Subvolume Layout

```
/ (btrfs top-level)
├── @                  # Root subvolume (snapshotted, mounted at /)
├── @home              # Home subvolume (snapshotted, mounted at /home)
├── @cache             # Pacman cache (excluded from snapshots)
├── @log               # Log files (excluded from snapshots)
└── @snapshots         # Snapper snapshots directory
```

## Installation Flow

1. **Preflight** — Root check, UEFI/BIOS detection, network check
2. **Interactive prompts** — Timezone (custom TUI with search), keyboard layout, disk selection, hostname, username, password
3. **Partitioning** — GPT + ESP (UEFI) or msdos + boot (BIOS), Btrfs root
4. **Btrfs subvolumes** — `@`, `@home`, `@cache`, `@log`, `@snapshots`
5. **Pacstrap** — Base system + desktop packages
6. **Fstab generation** — UUID-based mounts
7. **File copy** — Systemd services, snapper configs, first-boot scripts
8. **Chroot configuration** — Locale, timezone, hostname, users, mkinitcpio, greetd, services, snapper, first-boot service
9. **Limine install** — Deploy bootloader to ESP
10. **Desktop config deployment** — Copy configs to user home
11. **Finalize** — Write `/etc/aero-installed`, prompt reboot

## First Boot Flow

1. Triggered by `aero-firstboot.service` (ConditionPathExists: `/etc/aero-installed` + `!/etc/aero-firstboot-complete`)
2. Wait for network (up to 60s)
3. Install AUR packages via yay (`aur.packages`)
4. Install desktop packages via pacman (`desktop.packages`)
5. Create initial Snapper snapshots
6. Create XDG user directories
7. Run hardware detection
8. Apply branding (wallpaper, theme)
9. Write `/etc/aero-firstboot-complete`, disable service

## Hyprland Architecture

Configuration is modular, sourced from `hyprland.conf`:

```
~/.config/hypr/
├── hyprland.conf      # Main config, sources all others
├── monitors.conf      # Monitor layout and resolution
├── input.conf         # Keyboard, touchpad, mouse
├── binds.conf         # Keybindings
├── appearance.conf    # Animations, gaps, borders, colors
├── autostart.conf     # Startup applications
└── windowrules.conf   # Window rules per application
```

## Theme System

```
/usr/share/aero/themes/<name>/
├── colors.toml        # Color palette (consumed by aero-theme)
├── hyprland.conf      # Hyprland appearance overrides (optional)
├── waybar.css         # Waybar style overrides (optional)
├── ghostty.conf       # Ghostty color overrides (optional)
├── mako.conf          # Notification config override (optional)
├── walker.css         # Walker theme CSS (optional)
├── starship.toml      # Prompt style overrides (optional)
└── wallpaper.jpg      # Desktop wallpaper
```

Only `catppuccin` is currently defined. `aero-theme apply <name>` copies theme files to `~/.config/`, sets wallpaper, and reloads affected services.

## Coding Standards

- Shell scripts use `bash` with `set -euo pipefail`
- Inputs are validated before use
- Failures are handled gracefully with meaningful error messages
- Status messages printed inline for user visibility
- Important operations logged to install log
- Scripts are idempotent whenever practical
- No unnecessary dependencies
- Readability and maintainability preferred over cleverness
- Pure bash — no Python, no external interpreters

## Current Status

### Verified Working

- ISO builds reproducibly via `build.sh`
- UEFI boot via systemd-boot (15s timeout boot menu)
- BIOS boot via syslinux
- Live environment boots to greetd/tuigreet login screen
- Login as `liveuser` (no password) succeeds
- Hyprland launches with Waybar, wallpaper
- Ghostty terminal, Neovim, Zsh all work in live session
- Desktop keybindings functional
- `aero-install` launches from live shell
- Timezone selector (custom TUI with search) works
- Full installation runs to completion in QEMU
- Limine installed to ESP with correct config
- Installed system boots to greetd login

**Applied Fixes (all validated on live ISO):**
1. OVMF_VARS: corrected from OVMF_CODE to OVMF_VARS.4m.fd template; removed `2>/dev/null` masking
2. KEYMAP detection: replaced pipe-to-read subshell with `$(KEYMAP=...)` command substitution
3. snapper-boot.service: added `[Install]` section with `WantedBy=multi-user.target`
4. Snapper config overlay: custom settings reapplied after `snapper create-config` to preserve ALLOW_GROUPS, timeline limits, NUMBER_MIN_AGE
5. Walker: removed from `packages.x86_64` (not in core/extra); `walker-bin` already in `aur.packages`
6. Hyprland pseudotile: removed `dwindle { pseudotile = true }` — option deleted from Hyprland 0.55
7. Hyprland vfr: moved from `misc` to `debug` section — wiki lists `debug.vfr`, not `misc.vfr`
8. Ghostty gpu-accelerated: removed `gpu-accelerated = true` — option removed from Ghostty; GPU is always-on by design
9. snapper-boot ExecStart: replaced shell operators `2>/dev/null || true` with systemd `-ExecStart` prefix
10. yay build errors: removed `2>/dev/null` masking from git clone and makepkg in aero-install
11. windowrules.conf: migrated all 14 rules from `windowrulev2` to modern `windowrule` syntax — eliminates all Hyprland deprecation warnings
12. greetd/tuigreet launcher: switched from direct `Hyprland` binary to `start-hyprland` (uwsm wrapper) — eliminates the "start-hyprland" warning

### Known Issues

- BIOS bootloader installation broken — `$LIMINE_FLAG` variable not expanded inside quoted heredoc in aero-install.
- NVIDIA GPU detection pacman hook target is incorrect — `hardware-detect.sh` line 32 uses invalid `Target` directive with file path.
- `btop` and `lazygit` duplicated in both `packages.x86_64` and `desktop.packages`
- `archinstall` on ISO is unused (~2MB but unnecessary)
- `base-devel` on ISO adds ~200-300MB unnecessarily
- Root password silently set to user password (aero-install line 244)
- `linux-firmware` is largest ISO contributor (~700MB)

## Definition of Success

- [x] `mkarchiso` builds successfully
- [x] Produces a bootable ISO that boots to greetd+tuigreet
- [x] Live desktop (Hyprland, Waybar, Ghostty, Neovim, Zsh) fully functional — no deprecation warnings, clean uwsm launch
- [ ] Interactive installer completes without errors
- [ ] Installed system boots directly into Hyprland with Waybar
- [ ] First-boot automation (AUR packages, config deployment, snapper) succeeds
- [ ] Snapper snapshots work for root and home
- [ ] Networking, audio, and theming work on installed system
- [ ] System is clean, maintainable, and well-documented
