# Aero Linux — Project Status

**Version 0.1.0-alpha** — "Aero Alpha"

Last updated: 2026-06-13 (Alpha milestone)

Project status: **PRE-ALPHA → ALPHA**

Reason: Core architecture is complete. Installer finishes, Limine boots, system installs. Not feature-complete but past proof-of-concept.

Versioning: `Major.Minor.Patch` (e.g., `0.1.0-alpha`, `0.2.0-alpha`, `1.0.0`). All pre-1.0 versions carry the `-alpha` suffix.

---

## Completed

### Live Environment
- [x] ISO builds successfully (archiso)
- [x] UEFI boot via systemd-boot
- [x] greetd + tuigreet login with Aero branding
- [x] Hyprland desktop fully functional (no deprecation warnings)
- [x] Waybar, Ghostty, Neovim, Zsh, starship all working
- [x] Pacman keyring initialized on every live boot

### Installation Pipeline
- [x] Disk partitioning (GPT + ESP + Btrfs)
- [x] Btrfs subvolumes created (@, @home, @cache, @log, @snapshots)
- [x] Subvolume mounting with zstd compression
- [x] Pacstrap package installation completes
- [x] Locale, timezone, keymap configured in chroot
- [x] User created with groups and sudo access
- [x] yay AUR helper built from source (no password prompt)
- [x] mkinitcpio initramfs generated
- [x] greetd display manager configured
- [x] Limine bootloader: `BOOTX64.EFI` copied to ESP, `limine.conf` with `boot():/` kernel paths
- [x] Desktop configs deployed to user home
- [x] aero-firstboot.service enabled
- [x] Installer reaches "Installation complete" and reboot prompt
- [x] ESP mounted at `/boot` (kernel/initramfs on FAT, readable by Limine)

### Boot Architecture Fix (2026-06-13)
- [x] ESP mounted at `/boot` instead of `/efi` — kernel/initramfs on FAT32 for Limine compatibility
- [x] Removed broken `limine-install --efi /efi` (not available in chroot — `limine-mkinitcpio-hook` package not installed)
- [x] Direct binary copy: `cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI`
- [x] Config at `/boot/EFI/BOOT/limine.conf` with `boot():/vmlinuz-linux` kernel paths
- [x] Kernel/module paths fixed: previously `/boot/vmlinuz-linux` resolved relative to ESP root (wrong); now `boot():/vmlinuz-linux` correctly references ESP root
- [x] **Limine v12 config syntax fix**: `entry "Title"` → `/Title` — Limine's parser only recognizes `/` at line start as entry titles. `entry "..."` produced zero valid entries.
- [x] **Removed unsupported protocols**: `protocol: reboot` and `protocol: poweroff` removed (not in Limine v12's valid protocol list)
- [x] **OVMF_VARS fix**: stale `/tmp/OVMF_VARS.4m.fd` caused PXE fallthrough — deleting it restored boot to Limine
- [x] Pacman keyring: archiso-style boot-time initialization
- [x] Installer package installation: removed `pacstrap -K`
- [x] Password prompt: replaced `makepkg -si` with `makepkg -d` + `pacman -U`
- [x] Snapper: moved `create-config` from installer chroot to first boot
- [x] Disk selector: TUI rendering via `/dev/tty` instead of `>&2`

---

## In Progress

### Current Blocker — Black Screen After Limine Menu
- Limine menu displays correctly
- Default `/Aero Linux` entry selected
- Kernel/initramfs loaded? Unclear — no verbose output
- System does not reach greetd login
- **Next**: add `debug` to cmdline, remove `quiet`, verify root UUID, test fallback entry

### First Boot Validation (blocked by boot issue)
- [ ] Rebuild ISO (`sudo bash build.sh`)
- [ ] Delete old artifacts: `rm -f /tmp/aero-test-disk.qcow2 /tmp/OVMF_VARS.4m.fd`
- [ ] Install: `bash test.sh install`
- [ ] Boot installed system: `bash test.sh boot`
- [ ] Debug kernel boot (add verbose logging, verify UUID, test fallback)
- [ ] System reaches greetd login
- [ ] aero-firstboot.service runs:
  - [ ] Snapper create-config for root and home
  - [ ] AUR packages installed via yay
  - [ ] Initial snapper snapshots created
  - [ ] Branding applied
  - [ ] Hardware detection
  - [ ] Service disables itself

### Desktop Validation
- [ ] Hyprland launches after first-boot
- [ ] Waybar visible
- [ ] NetworkManager connected
- [ ] PipeWire audio functional
- [ ] Snapper snapshots work
- [ ] Reboot idempotency

---

## Known Bugs (Alpha)

### Boot Issues
- **Black screen after Limine menu**: default entry loads but system does not reach greetd. Cause unknown — may be kernel panic, missing root device, or initramfs issue. Need verbose logging (`debug` in cmdline, remove `quiet`).
- **Fallback entry untested**: `/Aero Linux (fallback)` — may have same or different failure mode.
- **No verbose output**: cmdline includes `quiet loglevel=3` which suppresses all kernel messages.
- **OVMF_VARS persistence**: stale `/tmp/OVMF_VARS.4m.fd` causes PXE fallthrough. Must delete before each boot test.

### Snapper
- `snapper -c root create-config /` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`. Root cause unknown. Diagnostics prove `/` and `/.snapshots` are valid Btrfs subvolumes. strace shows no failing Btrfs ioctls. Workaround: Snapper initialized on first boot via `aero-firstboot.service`.

### Installer
- Limited error handling — no recovery or rollback path.
- BIOS bootloader install broken (quoted heredoc + missing `limine-install` binary in chroot).
- `set -euo pipefail` combined with EXIT trap can unmount `/mnt` on any error.
- BIOS live boot via syslinux untested.

### Other
- NVIDIA GPU auto-detection pacman hook target incorrect.
- `btop`/`lazygit` duplicated in packages (cosmetic).
- `protocol: reboot` and `protocol: poweroff` removed (not supported in Limine v12).

---

## Alpha Roadmap

### Priority 1 — Fix Black-Screen Boot
- [ ] Add verbose kernel logging (remove `quiet`, add `debug` to cmdline)
- [ ] Verify root partition UUID in limine.conf matches blkid
- [ ] Test fallback initramfs entry
- [ ] Debug with early console output
- [ ] Verify initramfs contains btrfs module
- [ ] Test snapshot entry

### Priority 2 — First-Boot Service
- [ ] Snapper create-config for root and home
- [ ] AUR packages via yay
- [ ] Initial snapper snapshots
- [ ] Hardware detection
- [ ] Branding
- [ ] Service self-disable and idempotency

### Priority 3 — Desktop & Snapshot Workflow
- [ ] Hyprland launches after first-boot
- [ ] Waybar, Ghostty, NetworkManager, PipeWire
- [ ] Snapper snapshot creation and rollback
- [ ] Snapshot boot entry verification

### Priority 4 — Vim Philosophy Integration
- [ ] Home-row navigation everywhere
- [ ] Unified keybindings (Hyprland, Waybar, Ghostty, walker)
- [ ] Keyboard-first workflows
- [ ] System-wide motion consistency

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

## START HERE (For New Development Sessions)

### Current State
- **Version**: 0.1.0-alpha ("Aero Alpha")
- **Status**: Alpha — core architecture complete
- **Current Blocker**: Black screen after Limine menu

### Build & Test Commands
```bash
# Build ISO
sudo bash build.sh

# Clean test state
rm -f /tmp/aero-test-disk.qcow2 /tmp/OVMF_VARS.4m.fd

# Install (interactive TUI inside QEMU)
bash test.sh install

# Boot installed system
bash test.sh boot

# Cleanup only
bash test.sh cleanup
```

### Debugging the Black Screen
1. Modify limine.conf cmdline: remove `quiet loglevel=3`, add `debug systemd.log_level=debug`
2. Rebuild ISO with `sudo bash build.sh`, reinstall
3. If no output: try fallback initramfs entry
4. Check root=UUID matches actual partition
5. Verify initramfs includes btrfs: `lsinitramfs /boot/initramfs-linux.img | grep btrfs`

### Key Architecture Decisions
- ESP mounted at `/boot` (FAT32, kernel/initramfs on FAT for Limine compatibility)
- Limine v12 config uses `/Title` syntax (not `entry "Title"`)
- Kernel paths use `boot():/vmlinuz-linux` prefix
- Snapper initialization deferred to first-boot service
- All scripts are pure Bash — zero Python dependencies
- TUI rendering goes to `/dev/tty`, return values to stdout, logs to stderr
