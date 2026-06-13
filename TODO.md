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

### Boot Architecture Fix (2026-06-13)
- [x] Mount ESP at `/boot` instead of `/efi` (kernel/initramfs on FAT32, readable by Limine)
- [x] Remove reliance on `limine-install` (not available in chroot — only core `limine` package is pacstrapped)
- [x] Copy BOOTX64.EFI to `/boot/EFI/BOOT/BOOTX64.EFI` (UEFI fallback path, no NVRAM needed)
- [x] Write `limine.conf` at `/boot/EFI/BOOT/limine.conf` with `boot():/vmlinuz-linux` kernel paths
- [x] Fix broken kernel/module paths: previously `/boot/vmlinuz-linux` resolved relative to ESP root → did not exist; now `boot():/vmlinuz-linux` correctly references the ESP root
- [x] **Limine v12 config syntax**: replace `entry "Title"` with `/Title` — Limine's parser only recognizes lines starting with `/` as menu entries. The `entry "..."` syntax is GRUB/systemd-boot, not Limine. Every `/` in option values (e.g. `boot():/vmlinuz-linux`) was rejected by the `if *(p-2) != '\n'` line-start guard, causing "config file contains no valid entries".
- [x] Remove `protocol: reboot` and `protocol: poweroff` entries — not supported in Limine v12. Valid protocols: `linux`, `limine`, `multiboot1/2`, `efi`, `efi_boot_entry`, `bios`.
- [x] OVMF PXE issue was stale `/tmp/OVMF_VARS.4m.fd` — deleting this file fixed the PXE fallthrough
- [x] Fix OVMF_VARS in test.sh — copy OVMF_VARS.4m.fd instead of OVMF_CODE; remove `2>/dev/null` masking
- [x] Fix KEYMAP auto-detection in aero-install — replace pipe-to-read with `KEYMAP=$(...)` command substitution
- [x] Fix snapper-boot.service — add `[Install]` section with `WantedBy=multi-user.target`
- [x] Fix snapper config overwrite — reapply custom configs after `snapper create-config` in installer chroot
- [x] Fix Hyprland pseudotile — remove `dwindle { pseudotile = true }` (option deleted in 0.55)
- [x] Fix Hyprland vfr — move from `misc` to `debug` section (upstream change in 0.55)
- [x] Fix Ghostty gpu-accelerated — remove `gpu-accelerated = true` (option removed upstream)
- [x] Fix snapper-boot ExecStart — replace shell operators `2>/dev/null || true` with systemd `-ExecStart` prefix
- [x] Fix yay build error masking — remove `2>/dev/null` from git clone and makepkg in aero-install
- [x] Fix windowrules.conf — migrate all 14 `windowrulev2` rules to modern `windowrule` syntax (nofocus→no_focus, noanim→no_anim, float→float on, match: prefix)
- [x] Fix greetd/tuigreet launcher — switch from `--cmd Hyprland` to `--cmd start-hyprland` (uwsm wrapper) to eliminate "not recommended" warning
- [x] **Checkpoint: Live Environment Validation Passed** — ISO builds, UEFI boots, Hyprland desktop fully functional, no warnings
- [x] Fix select_opt Enter key — break case now matches `$'\n'|$'\r'` (not just `""`); return value via `echo "$sel"` (stdout) avoids `set -e` crash on non-zero index
- [x] Fix install log — move `exec 2>"$INSTALL_LOG"` from line 11 to after root `EUID` check (line 173), preventing permission error for non-root
- [x] Fix zsh config deployment — change `cp .../*` to `cp .../.` in customize_airootfs.sh to include dotfiles (`.zshrc`) in liveuser home
- [x] Fix aero-install alias — add `alias aero-install='sudo /usr/local/bin/aero-install'` to aliases.zsh
- [x] Fix parted dependency — add `parted` to packages.x86_64 (installer uses it for partitioning)
- [x] Fix disk selector rendering using `/dev/tty` — moved all interactive TUI rendering from `>&2` to `/dev/tty`
- [x] Fix live ISO pacman keyring — added `etc-pacman.d-gnupg.mount` + `pacman-init.service` + `multi-user.target.wants/` symlink (matching archiso releng)
- [x] Fix yay installation interactive sudo prompt — replaced `makepkg -si` (triggers sudo password prompt) with `makepkg -d` + root `pacman -U` (no sudo calls)

### Validation Progress (2026-06-13)
- [x] Installer launches from liveuser
- [x] aero-install alias works
- [x] Root escalation works
- [x] Timezone selection works
- [x] Disk selection renders correctly
- [x] Disk selection state matches selected device
- [x] Partitioning succeeds (parted)
- [x] Filesystem creation succeeds (mkfs.btrfs, mkfs.fat)
- [x] Btrfs subvolume creation succeeds
- [x] Subvolume mounting succeeds
- [x] pacstrap installs all packages
- [x] arch-chroot locale/timezone/keymap configuration
- [x] User creation with groups and sudo
- [x] yay AUR helper build and install
- [x] mkinitcpio initramfs generation
- [x] greetd display manager configuration
- [x] First-boot service enabled
- [x] Limine bootloader installed to ESP
- [x] Desktop configs deployed
- [x] Installer reaches "Installation complete" and reboot prompt

---

## Current Phase: First Boot Validation

### Priority 1 — First Boot Validation

- [ ] Rebuild ISO (`sudo bash build.sh`)
- [ ] Delete old test artifacts: `rm -f /tmp/aero-test-disk.qcow2 /tmp/OVMF_VARS.4m.fd`
- [ ] Install: `bash test.sh install`
- [ ] Boot installed system: `bash test.sh boot`
- [ ] Limine menu appears and boots default entry (`/Aero Linux` — `boot():/vmlinuz-linux`)
- [ ] System reaches greetd/tuigreet login screen
- [ ] Login with created user succeeds

### Priority 2 — First-Boot Service
- [ ] Snapper configuration:
  - [ ] `snapper -c root create-config /` succeeds on first boot
  - [ ] `snapper -c home create-config /home` succeeds on first boot
  - [ ] Aero snapper config templates applied
  - [ ] `snapper-boot.service` enabled
- [ ] AUR packages install via yay (network permitting)
- [ ] Initial snapper snapshots created
- [ ] Hardware detection runs
- [ ] Branding applied (wallpaper, theme)
- [ ] First-boot service disables itself
- [ ] `/etc/aero-firstboot-complete` marker created

### Priority 3 — Desktop Validation
- [ ] Hyprland launches after first-boot completes
- [ ] Waybar visible
- [ ] Ghostty terminal works
- [ ] NetworkManager connects (DHCP)
- [ ] PipeWire audio functional
- [ ] yay command available and works
- [ ] pamac/custom package install works
- [ ] Snapper snapshots can be created manually
- [ ] `snapper list` shows root and home configs

### Priority 4 — Idempotency
- [ ] Reboot first-boot does NOT run again
- [ ] Reboot snapper-boot creates boot-time snapshots
- [ ] Reboot Hyprland desktop still functional

---

## Future

- [ ] **Hyprland Lua migration** — migrate remaining configs from hyprlang to Lua API (`hl.*`). `windowrules.conf` already converted to modern hyprlang; full Lua migration postponed until after install validation.
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
- Snapper initialization (create-config) runs inside first-boot, NOT in the installer chroot (workaround for snapper 0.13.1 arch-chroot failure).
- `snapper-boot.service` has `[Install]` section with `WantedBy=multi-user.target`.
- `profiledef.sh` boot modes (`bios.syslinux`, `uefi.systemd-boot`) are for the LIVE ISO only. The installed system uses Limine.
- greetd + tuigreet provide lightweight TTY-based login (no X11 display manager).
- Snapper configured for root (`@`) and home (`@home`) subvolumes.
- Target ISO size: ~800MB (currently ~1.8GB before compression / ~1.0-1.2GB after zstd squashfs).
- Current ISO is ~1.8GB due to `linux-firmware` (~700MB) and `base-devel` (~200-300MB).
- walker is not in core/extra repos; must be installed from AUR as `walker-bin`.
- Installer writes `/etc/aero-install.conf` during installation for first-boot to read.
- No Python files or dependencies exist in the repo. All scripts are `#!/bin/bash`.
- **Boot Architecture Fix applied 2026-06-13:** ESP mounted at `/boot`, `limine-install --efi` replaced with `cp BOOTX64.EFI`, kernel paths use `boot():/` prefix. Next phase: first-boot validation on installed system.
