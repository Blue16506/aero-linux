# Aero Linux — TODO

**Version 0.3.0-pre** — "First Boot"

Project status: ALPHA — First usable Hyprland session achieved. Snapper (P1) migration to deferred first-boot init complete, verified on QEMU with zero failed services. Audio alsa-utils (P2), Login banner (P3) outstanding.

---

## Philosophy

**Aero Linux is a Vim Motion Philosophy Distribution.**

### Goals
- Hands remain on the home row
- Entire operating system keyboard-first
- Hyprland workflow optimized for Vim motions
- Mouse optional, not required
- Consistent keybindings across all interfaces
- Every workflow composable and scriptable

### Design Principles
1. Home-row-first interaction
2. Keyboard-first by default
3. Minimal friction
4. Speed through muscle memory
5. Discoverable but powerful
6. Consistency over novelty
7. Unix philosophy and composability

---
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

### Snapper Fix (2026-06-17) — Deferred to First Boot
- [x] Changed architecture: Snapper init moved from installer chroot to `aero-firstboot.service` (first boot)
- [x] Removed `snapper -c root create-config /` and `snapper -c home create-config /home` from installer (Phase 8)
- [x] Removed config overlay from installer (Phase 8)
- [x] Removed `systemctl enable snapper-boot` from installer (Phase 8)
- [x] Added `snapper` to `packages.x86_64` — installer only action is to install the package
- [x] Added Aero config template copy to `/usr/share/aero/configs/snapper/` in installer (Phase 7)
- [x] Added `systemctl enable snapper-boot.service snapper-cleanup.timer snapper-timeline.timer` in installer
- [x] Updated `first-boot.sh` Phase 2 — handles all Snapper init: create-config, subvolume creation, config overlay, initial snapshots
- [x] Added idempotent guards in `first-boot.sh` — skips if `/etc/snapper/configs/root` exists
- [x] Updated all docs to reflect deferred Snapper init architecture

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

## Known Bugs (Alpha)

### P1 — Snapper — **VERIFIED (Deferred to First Boot)**
- [x] Root cause: `snapper create-config` fails inside `arch-chroot` (no Btrfs kernel/udev support)
- [x] Changed architecture: Snapper init deferred to `aero-firstboot.service` on first boot
- [x] Installer only installs snapper, copies config templates, enables services
- [x] `first-boot.sh` Phase 1 handles all Snapper init with idempotent guards
- [x] Service ordering cycle fixed (removed `After=graphical.target`)
- [x] Diagnostics added (ERR trap, phase logging)
- [x] Verified on QEMU: root + home configs, valid subvolumes, initial snapshots, zero failed services
- [ ] Verify snapshot boot entry (`/Aero Linux (snapshot)`)

### P2 — Audio: alsa-utils Missing
- [ ] Package `alsa-utils` (add to `packages.x86_64` or `desktop.packages`)
- [ ] Verify audio output: `speaker-test` or `pw-play`

### P3 — Login Banner
- [ ] Fix `/etc/os-release` PRETTY_NAME from `Linux` to `Aero Linux`

### Test Infrastructure
- [ ] OVMF_VARS persistence — stale state causes PXE fallthrough. Use `install --clean`.
- [ ] Test disk reuse — qcow2 not overwritten on re-install. Use `install --clean`.

### Installer
- [ ] Limited error handling — no recovery or rollback path.
- [ ] BIOS bootloader install broken (quoted heredoc + missing `limine-install`).

### Other
- [ ] NVIDIA GPU auto-detection pacman hook target incorrect.
- [ ] `btop`/`lazygit` duplicated in packages (cosmetic).

---

## Current Phase: Alpha Stabilization

### Priority 1 — Fix Snapper Integration — **VERIFIED**
- [x] Root cause: `snapper create-config` fails inside `arch-chroot` (no Btrfs kernel/udev)
- [x] Changed architecture: Snapper init deferred to `aero-firstboot.service`
- [x] Installer: installs snapper, copies config templates, enables services
- [x] `first-boot.sh` Phase 1 handles create-config, subvolume creation, config overlay, snapshots
- [x] Idempotent guards in `first-boot.sh` — skips if configs already exist
- [x] Service ordering cycle fixed (removed `After=graphical.target`)
- [x] Diagnostics added (ERR trap, phase logging)
- [x] Verified on QEMU: `snapper list-configs`, `btrfs subvolume show`, `systemctl --failed` = 0
- [ ] Verify snapshot boot entry (`/Aero Linux (snapshot)`)

### Priority 2 — Fix Audio Stack
- [ ] Package `alsa-utils` (add to `packages.x86_64` or `desktop.packages`)
- [ ] Test audio: `speaker-test -c 2 -l 1 -t wav` or `pw-play`
- [ ] Investigate `auto_null` default sink — configure PipeWire ALSA compatibility

### Priority 3 — Fix Login Branding
- [ ] Update `/etc/os-release` PRETTY_NAME from `Linux` to `Aero Linux`

### Priority 4 — Begin Vim Motion Philosophy Implementation
- [ ] Design home-row navigation scheme for Hyprland (Super + hjkl / vim-style)
- [ ] Document unified keybinding philosophy
- [ ] Implement consistent keybindings across Hyprland, Waybar, Ghostty, walker
- [ ] Keyboard-first workflow documentation

### Priority 5 — Polish & Bug Fixes
- [ ] Installer error handling and recovery
- [ ] BIOS bootloader fix
- [ ] NVIDIA pacman hook fix
- [ ] `btop`/`lazygit` duplication cleanup
- [ ] Bluetooth auto-configuration
- [ ] Firewall pre-configuration
- [ ] Kernel selection in installer
- [ ] LUKS encryption support
- [ ] ISO size reduction
- [ ] Automated ISO release pipeline

---

## Snapper Architecture (Final Design)

### Why Initialization Was Moved to First Boot

`snapper create-config` consistently failed inside `arch-chroot` during installation. The chroot environment lacks the Btrfs kernel module and udev device nodes required for Snapper to create nested subvolumes. Running `snapper create-config` in a chroot is fundamentally unreliable.

### Debugging Journey

1. **Initial hypothesis**: Installer pre-created `@snapshots` subvolume, conflicting with Snapper.
2. **Revised finding**: Even without pre-created subvolumes, `snapper create-config` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`.
3. **Root cause**: `arch-chroot` does not expose Btrfs kernel capabilities or udev device nodes needed by Snapper. The chrooted `snapper` binary cannot create Btrfs subvolumes.
4. **Resolution**: Deferred all Snapper initialization to `aero-firstboot.service` on first boot, where the full Btrfs-capable kernel and udev are available.
5. **Additional fixes**: Removed `After=graphical.target` from service unit (caused ordering cycle with `WantedBy=multi-user.target`), added `|| true` guards to non-critical operations, added diagnostics via `trap` and phase logging.

### Advantages of the Final Design

- **Simpler installer** — no `snapper create-config`, config overlay, or subvolume management during installation
- **More reliable Snapper setup** — runs on the booted system with full Btrfs kernel support and udev
- **Easier debugging** — phase boundary logging and ERR trap capture failures with exact line numbers
- **Idempotent initialization** — multiple re-executions of `aero-firstboot.service` are safe
- **Zero failed services** — `systemctl --failed` returns zero after all ordering and robustness fixes
- **Cleaner separation** — installer owns system installation; first-boot owns post-install configuration

---

## Notes

- Desktop configs live in `/usr/share/aero/configs/` on the ISO and are copied to `~/.config/` by the installer (Phase 10).
- Config directory list is duplicated in `customize_airootfs.sh:60` and `aero-install:535` — must keep in sync.
- `aero-firstboot.service` runs once per system (ConditionPathExists on `/etc/aero-installed` and `!/etc/aero-firstboot-complete`). No `After=` or `Wants=` ordering — the script manages its own network wait; Snapper init (Phase 1) is purely local.
- Snapper initialization is deferred to `aero-firstboot.service` on first boot. The installer only installs snapper, copies config templates to `/usr/share/aero/configs/snapper/`, and enables `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer`. `first-boot.sh` handles all actual Snapper init (create-config, subvolume creation, config overlay, initial snapshots) with idempotent guards. **Verified on QEMU**.
- `profiledef.sh` boot modes (`bios.syslinux`, `uefi.systemd-boot`) are for the LIVE ISO only. The installed system uses Limine.
- greetd + tuigreet provide lightweight TTY-based login (no X11 display manager).
- Snapper configured for root (`@`) and home (`@home`) subvolumes.
- Target ISO size: ~800MB (currently ~1.8GB before compression / ~1.0-1.2GB after zstd squashfs).
- Current ISO is ~1.8GB due to `linux-firmware` (~700MB) and `base-devel` (~200-300MB).
- walker is not in core/extra repos; must be installed from AUR as `walker-bin`.
- Installer writes `/etc/aero-install.conf` during installation for first-boot to read.
- No Python files or dependencies exist in the repo. All scripts are `#!/bin/bash`.
- **Version 0.3.0-pre** — "First Boot". First usable Hyprland session. Snapper (P1) deferred to first-boot init, **verified on QEMU**. Audio alsa-utils (P2) pending.
- Philosophy: Vim Motion Philosophy Distribution — keyboard-first, home-row-centric, mouse-optional.

---

## Session Summary — 2026-06-17

### What Was Accomplished
1. **Root cause confirmed**: `snapper create-config` fails inside `arch-chroot` — the chroot lacks Btrfs kernel module and udev device nodes.
2. **Architecture redesign**: Snapper initialization moved entirely to `aero-firstboot.service` on first boot.
3. **Service ordering bug fixed**: Removed `After=graphical.target` from service unit (caused cycle with `WantedBy=multi-user.target`).
4. **Robustness improved**: Added ERR trap, phase logging, `|| true` guards on non-critical operations, `exit 0`.
5. **End-to-end verification**: ISO rebuilt, installed via QEMU, booted, validated — all Snapper features working, zero failed services.

### Files Changed (this session)
- `airootfs/etc/systemd/system/aero-firstboot.service` — removed `After=graphical.target`, added logger diagnostics
- `airootfs/usr/share/aero/scripts/first-boot.sh` — ERR trap, phase logging, guarded mkdir ops, `exit 0`
- `airootfs/usr/local/bin/aero-install` — fixed `INSTALL_LOG` unbound variable
- All 5 docs — updated to VERIFIED status, added Snapper Architecture section

### Next Steps
1. **P2 (Audio)**: Add `alsa-utils` to `packages.x86_64`, rebuild ISO, test audio via QEMU.
2. **P3 (Branding)**: Update `/etc/os-release` PRETTY_NAME to `Aero Linux`.
3. **Vim Motion Philosophy**: Begin home-row navigation design.
