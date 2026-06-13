# Aero Linux

**Version 0.1.0-alpha — codename "Aero Alpha"**

A modern Arch-based Linux distribution focused on simplicity, performance, reliability, and a keyboard-first Hyprland desktop experience.

> Current Status: **ALPHA — Core architecture complete. Limine boots, installer works, system installs.**

Versioning: Major.Minor.Patch (e.g., `0.1.0-alpha`, `0.2.0-alpha`, `1.0.0`). Pre-1.0 versions use the `-alpha` suffix.

---

## Philosophy

**Aero Linux is a Vim Motion Philosophy Distribution.**

### Goals
- Hands remain on the home row
- Entire operating system should be keyboard-first
- Hyprland workflow optimized for Vim motions
- Minimize hand movement
- Consistent keybindings across TUI, terminal, window manager, file manager, launcher, and system utilities
- Mouse should be optional, not required
- Every workflow should be composable and scriptable

### Design Principles
1. Home-row-first interaction
2. Keyboard-first by default
3. Minimal friction
4. Speed through muscle memory
5. Discoverable but powerful
6. Consistency over novelty
7. Unix philosophy and composability

---
* Arch Linux base
* Hyprland Wayland desktop
* greetd + tuigreet login manager
* Ghostty terminal
* Waybar status bar
* Btrfs filesystem with Snapper snapshots
* Limine bootloader (UEFI + BIOS)
* Interactive TUI installer
* Modular desktop configuration
* Custom Aero branding
* Reproducible ISO builds

---

## Screenshots

Screenshots coming soon.

---

## Project Goals

Aero Linux aims to provide:

* Easy installation
* Modern Wayland desktop experience
* Reliable system rollback
* Fast boot times
* Consistent design
* Modular configuration
* Simple maintenance
* Reproducible builds

---

## Technology Stack

| Component     | Technology        |
| ------------- | ----------------- |
| Base          | Arch Linux        |
| ISO Builder   | archiso           |
| Bootloader    | Limine            |
| Filesystem    | Btrfs             |
| Snapshots     | Snapper           |
| Desktop       | Hyprland          |
| Terminal      | Ghostty           |
| Status Bar    | Waybar            |
| Login Manager | greetd + tuigreet |
| Shell         | zsh               |
| Networking    | NetworkManager    |
| Audio         | PipeWire          |
| Bluetooth     | BlueZ             |

---

## Current Status

### Alpha Milestone: 0.1.0-alpha — Core Architecture Complete

The project has moved from PRE-ALPHA (proof-of-concept) to ALPHA (core architecture exists, not feature-complete).

#### Achievements
- ✅ ISO builds and boots in UEFI (systemd-boot live, Limine installed)
- ✅ Hyprland desktop fully functional in live environment
- ✅ Interactive TUI installer (partitioning, subvolumes, pacstrap, arch-chroot)
- ✅ Btrfs filesystem with subvolumes and Snapper
- ✅ Limine UEFI bootloader: ESP layout, BOOTX64.EFI, limine.conf all verified
- ✅ OVMF_VARS stale-state issue identified and workaround documented
- ✅ Limine v12 config syntax fixed (`entry "Title"` → `/Title`)
- ✅ Snapper initialization deferred to first boot (arch-chroot workaround)
- ✅ yay AUR helper built during installation
- ✅ greetd + tuigreet display manager configured

#### Current Blocker
- Installed system reaches Limine menu but kernel boot results in black screen
- Need kernel/initramfs debugging, verbose boot logging, root mount verification

#### Validation Status

| Component | Status |
|---|---|
| Live ISO boot (UEFI) | ✅ verified |
| Installation pipeline | ✅ verified |
| Limine menu display | ✅ verified |
| Boot into installed system | 🔴 blocked (black screen) |
| First-boot service | ⏳ pending |
| Hyprland desktop | ⏳ pending |
| Snapper snapshots | ⏳ pending |
| BIOS boot path | 🔴 broken (separate issue) |

---

## Known Bugs (Alpha)

### Boot Issues
- **Black screen after Limine menu**: default entry selects kernel + initramfs but system does not reach greetd. Need verbose boot logging, root mount verification, initramfs verification.
- **Fallback entry untested**: `/Aero Linux (fallback)` may have same issue or different failure mode.
- **No verbose kernel output**: cmdline includes `quiet loglevel=3` — must add `debug` or remove `quiet` for diagnosis.

### Snapper
- `snapper -c root create-config /` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`. Root cause unknown — `/` is a valid Btrfs subvolume (inode 256), `/.snapshots` is valid. Workaround: Snapper initialized on first boot via `aero-firstboot.service`.

### Test Infrastructure
- `/tmp/OVMF_VARS.4m.fd` persists across sessions and can create stale UEFI boot state. Must delete before boot testing.
- `/tmp/aero-test-disk.qcow2` is reused without warning — must manually delete before re-installing.

### Installer
- Limited error handling: if any step fails inside the heredoc, recovery requires restarting from scratch.
- No rollback path: partially installed system must be manually cleaned up.
- BIOS bootloader path is broken (quoted heredoc + missing `limine-install` binary in chroot).

---

## Alpha Roadmap

### Priority 1 — Fix Black-Screen Boot
- [ ] Add verbose boot logging (remove `quiet`, add `debug` to cmdline)
- [ ] Verify root partition mounting (UUID match in limine.conf vs blkid)
- [ ] Test fallback initramfs entry
- [ ] Debug kernel boot with early console output
- [ ] Verify initramfs contains btrfs module

### Priority 2 — First-Boot Service
- [ ] Snapper create-config for root and home on first boot
- [ ] AUR packages install via yay
- [ ] Initial snapper snapshots
- [ ] Hardware detection, branding, service self-disable
- [ ] Reboot idempotency

### Priority 3 — Desktop Validation
- [ ] Hyprland launches after first-boot
- [ ] Waybar, Ghostty, NetworkManager, PipeWire functional
- [ ] Snapper snapshot creation and rollback workflow
- [ ] Snapshot boot entry verification

### Priority 4 — Vim Philosophy Integration
- [ ] Home-row navigation everywhere
- [ ] Unified keybindings across Hyprland, Waybar, Ghostty, walker
- [ ] Keyboard-first workflows
- [ ] System-wide motion consistency

### Known Issues (carried forward)
| Issue | Impact | Status |
|---|---|---|
| Snapper create-config fails in arch-chroot | Snapper not configured during install | Workaround: first-boot init |
| BIOS bootloader install broken | BIOS installation unsupported | Unfixed |
| BIOS live boot via syslinux untested | BIOS path unvalidated | Unfixed |
| NVIDIA hook target incorrect | NVIDIA systems need manual fix | Unfixed |
| `btop`/`lazygit` duplicated in packages | Cosmetic | Unfixed |

---

## Building the ISO

### Requirements

* Arch Linux host
* archiso
* limine

### Build

```bash
git clone https://github.com/Blue16506/aero-linux.git
cd aero-linux

sudo ./build.sh
```

The generated ISO will be placed in:

```text
out/
```

---

## Installation

Boot the Aero Linux ISO and run:

```bash
aero-install
```

The installer will:

* Detect boot mode
* Configure disks (GPT ESP + Btrfs)
* Create Btrfs subvolumes (@, @home, @cache, @log, @snapshots)
* Install the base system (pacstrap)
* Configure users, locale, timezone, keymap
* Build yay AUR helper
* Install Limine bootloader
* Enable services (greetd, NetworkManager, first-boot)
* Deploy desktop configurations
* Snapper is configured on first boot by aero-firstboot.service

---

## Directory Layout

```text
aero/
├── airootfs/
├── efiboot/
├── limine/
├── syslinux/
├── build.sh
├── packages.x86_64
├── profiledef.sh
├── PROJECT_CONTEXT.md
└── TODO.md
```

---

## Project Structure

Desktop configurations are modular:

```text
Hyprland
├── monitors.conf
├── input.conf
├── binds.conf
├── appearance.conf
├── autostart.conf
└── windowrules.conf
```

All desktop configurations live under:

```text
/usr/share/aero/configs/
```

and are deployed automatically during first boot.

---

## Development Status

Aero Linux has entered **Alpha**. The core architecture is complete:
- ISO builds and boots
- Installer completes successfully
- Limine bootloader displays menu
- Btrfs subvolumes, Snapper, greetd, yay all integrated

Development is now focused on:
1. Fixing black-screen boot issue (kernel/initramfs debugging)
2. First-boot service validation
3. Desktop and snapshot workflow validation
4. Vim-motion philosophy integration

---

## START HERE (For New Development Sessions)

### Current State
- **Version**: 0.1.0-alpha ("Aero Alpha")
- **Status**: Alpha — core architecture exists, not feature-complete
- **Current blocker**: Installed system reaches Limine menu but kernel boot produces black screen

### Immediate Next Actions

```bash
# 1. Rebuild ISO
sudo bash build.sh

# 2. Clean test state
rm -f /tmp/aero-test-disk.qcow2 /tmp/OVMF_VARS.4m.fd

# 3. Install (inside QEMU, walk through TUI installer)
bash test.sh install

# 4. Boot installed system
bash test.sh boot
```

### What To Debug (black screen after Limine menu)
- Add `debug` or remove `quiet loglevel=3` from limine.conf cmdline to see kernel output
- Verify `root=UUID=...` in limine.conf matches actual root partition UUID
- Verify `vmlinuz-linux` and `initramfs-linux.img` exist at `boot():/` on the ESP
- Test fallback initramfs entry
- Check initramfs includes btrfs module (`lsinitramfs /boot/initramfs-linux.img | grep btrfs`)

### Expected Outcomes
- Limine menu shows `/Aero Linux`, `/Aero Linux (fallback)`, `/Aero Linux (snapshot)`
- Default entry should boot kernel, mount root, reach greetd
- First boot: `aero-firstboot.service` initializes Snapper, installs AUR packages

### Known Pitfalls
- Always delete `/tmp/OVMF_VARS.4m.fd` before boot testing (stale UEFI state causes PXE fallthrough)
- Always delete `/tmp/aero-test-disk.qcow2` before re-installing (old install data persists)
- Snapper `create-config` fails inside arch-chroot — do not attempt to fix, workaround already in place
- BIOS boot path is broken — UEFI-only for now

### Key Files
- `airootfs/usr/local/bin/aero-install` — installer script (Phase 1-11)
- `airootfs/usr/share/aero/scripts/first-boot.sh` — first-boot service
- `test.sh` — QEMU test runner (live/install/boot/cleanup modes)
- `build.sh` — ISO builder wrapper

### Testing Checklist
- [ ] Clean state established (`rm -f /tmp/aero-test-disk.qcow2 /tmp/OVMF_VARS.4m.fd`)
- [ ] ISO builds without error
- [ ] `bash test.sh install` completes through reboot prompt
- [ ] `bash test.sh boot` shows Limine menu
- [ ] Default entry boots and reaches greetd
- [ ] Login works, first-boot service runs
- [ ] Hyprland desktop, network, audio functional
- [ ] Snapper snapshots created
- [ ] Reboot is idempotent

---

## License

License to be determined.
