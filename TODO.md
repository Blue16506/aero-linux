# Aero Linux — TODO

## Completed

### Core Infrastructure
- [x] Create archiso profile directory structure
- [x] Create `packages.x86_64` with Hyprland, Ghostty, greetd, zsh, etc.
- [x] Create `profiledef.sh` with bootmodes and file permissions
- [x] Create `pacman.conf` with core/extra repos
- [x] Create `build.sh` — ISO build wrapper
- [x] Create `test.sh` — QEMU test helper
- [x] Create `TESTING.md` — manual test checklist

### System Configuration
- [x] Create `mkinitcpio.conf` with btrfs hooks
- [x] Create `airootfs/etc/limine.conf` — installed system bootloader template
- [x] Create `airootfs/etc/greetd/config.toml` with tuigreet
- [x] Create `airootfs/etc/pam.d/greetd`
- [x] Create `airootfs/etc/snapper/config-templates/root` and `/home`
- [x] Create `airootfs/etc/sudoers.d/aero-installer`
- [x] Create `airootfs/etc/pacman.d/mirrorlist`
- [x] Create `airootfs/etc/zsh/zshenv`
- [x] Create `airootfs/etc/os-release`

### Systemd Services
- [x] Create `airootfs/etc/systemd/system/aero-firstboot.service`
- [x] Create `airootfs/etc/systemd/system/snapper-boot.service`

### Installer & First Boot
- [x] Create `airootfs/usr/local/bin/aero-install` — interactive installer (576 lines)
- [x] Create `airootfs/usr/share/aero/scripts/first-boot.sh` — post-install setup
- [x] Create `airootfs/usr/share/aero/scripts/hardware-detect.sh` — GPU/CPU detection
- [x] Create `airootfs/usr/local/bin/aero-greeter` — greetd wrapper for tuigreet
- [x] Create `airootfs/usr/local/bin/aero-theme` — theme switching CLI

### Live Environment
- [x] Create `airootfs/root/customize_airootfs.sh` — archiso post-build customization
- [x] Create `airootfs/root/.zshrc` — live shell config
- [x] Create `airootfs/root/.automated_script.sh`
- [x] Create `airootfs/root/.config/starship.toml`

### Desktop Configuration
- [x] Modular Hyprland configs (7 files): hyprland.conf, monitors, input, binds, appearance, autostart, windowrules
- [x] Waybar config + style (2 files)
- [x] Ghostty terminal config
- [x] Zsh user config (6 files): .zshrc, aliases, plugins, completion, keybindings, theme
- [x] Mako notification config
- [x] Wlogout power menu (layout + style)
- [x] Walker launcher config + Catppuccin theme CSS
- [x] Snapper configs for installed system (`/usr/share/aero/configs/snapper/`)

### Branding & Themes
- [x] Create default wallpaper (Catppuccin gradient, 4K)
- [x] Create Catppuccin Mocha theme (colors.toml + wallpaper.jpg)
- [x] Create `aur.packages` — AUR package list for first-boot
- [x] Create `desktop.packages` — desktop extras for first-boot

### Project Documentation
- [x] Create `PROJECT_CONTEXT.md` with full project documentation
- [x] Create `TODO.md` task tracking
- [x] Create `README.md`
- [x] Create `PROJECT_AUDIT.md` — comprehensive audit report

### Bug Fixes & Cleanup
- [x] Remove duplicate config copying from first-boot.sh (installer handles all configs)
- [x] Fix hardcoded UID 1000 in installer (dynamic lookup via arch-chroot id)
- [x] Simplify snapper-boot.service (remove fragile jq chain)
- [x] Clarify boot modes in profiledef.sh (ISO boot vs installed system)
- [x] Fix aero-firstboot.service ConditionPathExists (inverted logic)
- [x] Fix systemd service/snapper config copying paths in installer chroot
- [x] Add NVMe/mmcblk/loop partition naming support to installer
- [x] Fix `sudo -u` to `sudo -Hu` in first-boot.sh for proper $HOME
- [x] Remove walker from packages.x86_64 (not in core/extra); add walker-bin to aur.packages

---

## Critical

- [ ] Fix OVMF_VARS in test.sh (line 44 copies OVMF_CODE as VARS; should copy `/usr/share/edk2/x64/OVMF_VARS.4m.fd`)
- [ ] Fix KEYMAP auto-detection in aero-install (line 198: pipe subshell prevents variable assignment; use `KEYMAP=$(localectl status | grep "X11 Layout" | awk '{print $3}')`)
- [ ] Fix snapper-boot.service — add `[Install]` section with `WantedBy=multi-user.target` (currently inert)
- [ ] Fix snapper config duplication — pre-copied files (`$AERO_CONFIGS/snapper/root` and `/home`) are overwritten by `snapper create-config` in chroot
- [ ] Remove `archinstall` from `packages.x86_64` (unused; Aero has its own installer)
- [ ] Remove `btop` and `lazygit` from `desktop.packages` (already on ISO, installed by pacstrap)
- [ ] Fix duplicate config directory list between `customize_airootfs.sh` (line 60) and `aero-install` (line 535)

---

## Important

- [ ] Remove `base-devel` from `packages.x86_64` (adds ~200-300MB; only needed on installed system for yay/AUR builds)
- [ ] Remove `snapper` from `packages.x86_64` (only needed on installed system; pacstrapped during install)
- [ ] Remove `reflector` and `pacman-contrib` from `packages.x86_64` (not essential on live ISO)
- [ ] Fix yay build error masking in aero-install (lines 406-410: `2>/dev/null || true` hides failures)
- [ ] Fix hardware-detect.sh: pacman `Target` directive with file path (line 32) is invalid
- [ ] Fix hardware-detect.sh: all `pacman -S` calls masked with `|| true`
- [ ] Fix root password silently set to user password (aero-install line 244)
- [ ] Consider trimming `linux-firmware` (largest ISO contributor ~700MB; switch to `linux-firmware-whence` or reduce)
- [ ] Walker keybinding in live environment: `SUPER+SPACE` references walker which is not on the ISO

---

## Future

- [ ] Bluetooth auto-configuration
- [ ] NetworkManager iwd backend integration
- [ ] Firewall (ufw) pre-configuration
- [ ] `aero-update` script with pre/post snapper snapshots
- [ ] Kernel selection (linux-zen, linux-lts) in installer
- [ ] Plymouth boot splash with branding
- [ ] LUKS encryption support in installer
- [ ] NVIDIA GPU auto-detection and driver installation
- [ ] Printer support
- [ ] Virtual machine guest tools
- [ ] Package group selection in installer
- [ ] Automated ISO release pipeline
- [ ] Repository signing
- [ ] Custom wallpapers pack
- [ ] Aero-specific pacman repository

---

## Notes

- Desktop configs live in `/usr/share/aero/configs/` on the ISO and are copied to `~/.config/` by the installer (Phase 10).
- Config directory list is duplicated in `customize_airootfs.sh:60` and `aero-install:535` — must keep in sync.
- `aero-firstboot.service` runs only when `/etc/aero-installed` exists AND `/etc/aero-firstboot-complete` does not.
- `snapper-boot.service` has no `[Install]` section — currently dead code.
- `profiledef.sh` boot modes (`bios.syslinux`, `uefi.systemd-boot`) are for the LIVE ISO only. The installed system uses Limine.
- greetd + tuigreet provide lightweight TTY-based login (no X11 display manager).
- Snapper configured for root (`@`) and home (`@home`) subvolumes.
- Target ISO size: ~800MB (currently ~1.8GB before compression / ~1.0-1.2GB after zstd squashfs).
- Current ISO is ~1.8GB due to `linux-firmware` (~700MB) and `base-devel` (~200-300MB).
- walker is not in core/extra repos; must be installed from AUR as `walker-bin`.
- Installer writes `/etc/aero-install.conf` during installation for first-boot to read.
- No Python files or dependencies exist in the repo. All scripts are `#!/bin/bash`.
