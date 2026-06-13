# Aero Linux

**Version 0.1.1-alpha — codename "Aero Alpha"**

A bootable and installable Hyprland distribution in Alpha development. Keyboard-first, Vim-motion philosophy.

> Current Status: **ALPHA — First successful desktop boot achieved. System boots into Hyprland with terminal, Neovim, and hyprpaper wallpaper system.**

Versioning: `Major.Minor.Patch` (e.g., `0.1.1-alpha`, `0.2.0-alpha`, `1.0.0`). Pre-1.0 versions use the `-alpha` suffix.

---

## Philosophy

**Aero Linux is evolving into a Vim Motion Philosophy distribution.**

### Goal
Keep hands on the home row as much as possible. The entire desktop experience should be keyboard-centric and modal.

### Principles
- **Keyboard first** — every action reachable without leaving the keyboard
- **Home row first** — primary navigation binds to `j`, `k`, `l`, `;` or `h`, `j`, `k`, `l`
- **Minimal mouse usage** — mouse is optional, never required for core workflows
- **Consistent motions everywhere** — same keybindings work in Hyprland, terminal, file manager, launcher, TUI tools
- **Hyprland configured around modal workflows** — Super key as primary modifier, Vim-style navigation in window management
- **System applications follow Vim-inspired navigation** where feasible

### Design Principles
1. Home-row-first interaction
2. Keyboard-first by default
3. Minimal friction
4. Speed through muscle memory
5. Discoverable but powerful
6. Consistency over novelty
7. Unix philosophy and composability

### Long-term Objective
A complete keyboard-first operating system where the user rarely leaves the home row — from window management to file navigation to text editing to system administration.

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

### Milestone: v0.1.1-alpha — First Successful Desktop Boot

The installed system now boots successfully into a Hyprland desktop session with working terminal, Neovim, and wallpaper system. This marks Aero Linux's transition from proof-of-concept to functional Alpha.

#### Achievements (v0.1.1-alpha)
- ✅ ISO builds and boots (UEFI via systemd-boot)
- ✅ Interactive TUI installer (partitioning, subvolumes, pacstrap, arch-chroot)
- ✅ Btrfs filesystem with subvolumes (@, @home, @cache, @log, @snapshots)
- ✅ Limine UEFI bootloader: ESP layout, BOOTX64.EFI, limine.conf verified
- ✅ Limine v12 config syntax fixed (`entry "Title"` → `/Title`)
- ✅ Kernel boots from Limine via `boot():/vmlinuz-linux`
- ✅ Initramfs loads correctly
- ✅ Root filesystem mounts (Btrfs `@` subvolume)
- ✅ greetd + tuigreet display manager runs
- ✅ Hyprland launches and renders
- ✅ Waybar status bar appears
- ✅ Ghostty terminal works
- ✅ Neovim launches and is functional
- ✅ First successful desktop boot from installed system
- ✅ Wallpaper system migrated from swaybg to hyprpaper (Hyprland-native)
- ✅ test.sh auto-discovers newest ISO — no daily date hardcode edits
- ✅ test.sh supports `install --clean` for fresh qcow2 + OVMF state

#### Known Issues (carried forward)
- ❌ Snapper create-config fails in arch-chroot — workaround: first-boot init
- ❌ BIOS bootloader install broken (UEFI-only)
- ❌ NVIDIA GPU auto-detection hook target incorrect
- ❌ Limited installer error handling (no rollback path)
- ❌ `btop`/`lazygit` duplicated in packages

#### Validation Status

| Component | Status |
|---|---|
| Live ISO boot (UEFI) | ✅ verified |
| Installation pipeline | ✅ verified |
| Limine menu display | ✅ verified |
| Kernel boot + root mount | ✅ verified |
| Hyprland desktop (installed) | ✅ verified |
| Waybar, Ghostty (installed) | ✅ verified |
| Neovim (installed) | ✅ verified |
| Wallpaper display (hyprpaper) | ✅ fixed — pending rebuild verification |
| First-boot service | ⏳ pending validation |
| Snapper snapshots | ⏳ pending validation |
| NetworkManager, PipeWire, yay | ⏳ pending validation |
| Snapshot boot entry | ⏳ pending validation |
| BIOS boot path | 🔴 broken (UEFI-only) |

---

## Known Bugs (Alpha)

### Desktop & Login
- **Linux PRETTY_NAME appears in login banner**: `tuigreet` displays `Linux` from `/etc/os-release` `PRETTY_NAME` field instead of `Aero Linux`. Need to update `/etc/os-release` to show correct branding in the login prompt.
- **Empty home directory**: Fresh user home may be empty (missing `~/Desktop`, `~/Downloads`, etc.) — `xdg-user-dirs-update` runs in first-boot but may not create directories if XDG config is absent.
- **Desktop wallpaper currently intentionally black**: The wallpaper migration to hyprpaper is complete. The default background is black until the first-boot service runs `aero-theme apply catppuccin`. This is by design.

### Snapper
- `snapper -c root create-config /` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`. Root cause unknown — `/` is a valid Btrfs subvolume (inode 256), `/.snapshots` is valid. Workaround: Snapper initialized on first boot via `aero-firstboot.service`.

### Service Validation (untested)
- **NetworkManager**: DHCP connectivity in QEMU user NAT untested.
- **PipeWire audio**: Audio output not yet verified.
- **yay AUR helper**: Package installation from AUR untested.
- **first-boot service**: Full end-to-end run not yet validated.
- **snapper-boot.service**: Snapshot boot entry (`/Aero Linux (snapshot)`) untested.

### Test Infrastructure
- `/tmp/OVMF_VARS.4m.fd` persists across QEMU sessions — stale UEFI boot state can cause PXE fallthrough. Use `install --clean` or delete manually.
- `/tmp/aero-test-disk.qcow2` is NOT overwritten on re-install — old install data persists. Use `install --clean` to start fresh.

### Installer
- Limited error handling: if any step fails inside the heredoc, recovery requires restarting from scratch.
- No rollback path: partially installed system must be manually cleaned up.
- BIOS bootloader path is broken (quoted heredoc + missing `limine-install` binary in chroot).

### Other
- NVIDIA GPU auto-detection pacman hook target incorrect (uses file path instead of package name).
- `btop`/`lazygit` duplicated in both `packages.x86_64` and `desktop.packages`.
- `snapper-boot.service` lacks `[Install]` section — never enabled by any script.

---

## Roadmap: Alpha Stabilization

Phase goal: Stabilize the Alpha by completing system validation, fixing remaining bugs, and beginning Vim Motion Philosophy integration.

### Priority 1 — Complete System Validation
- [ ] Fix login banner: update `/etc/os-release` PRETTY_NAME
- [ ] Verify NetworkManager connects (DHCP in QEMU user NAT)
- [ ] Verify PipeWire audio functional
- [ ] Verify yay AUR helper installs packages
- [ ] Verify first-boot.service runs end-to-end:
  - [ ] Snapper create-config (root + home)
  - [ ] AUR packages installed
  - [ ] Initial snapshots created
  - [ ] Service self-disables, `/etc/aero-firstboot-complete` created
- [ ] Verify snapper-boot.service
- [ ] Verify snapshot boot entry (`/Aero Linux (snapshot)`)
- [ ] Reboot idempotency (first-boot does NOT run again)
- [ ] Verify empty home directory investigation

### Priority 2 — Begin Vim Motion Philosophy Implementation
- [ ] Home-row navigation in Hyprland (Super + hjkl / vim-style keys)
- [ ] Unified keybindings across launcher, file manager, terminal, TUI
- [ ] Keyboard-first workflows (mouse optional)
- [ ] System-wide motion consistency design document

### Priority 3 — Home-Row-First Desktop Experience
- [ ] Vim-style navigation across entire OS
- [ ] Consistent keybinding philosophy documented
- [ ] Reduce mouse dependency wherever possible
- [ ] Modal workflow design for desktop interaction

### Priority 4 — Polish & UX Improvements
- [ ] Installer error handling and recovery
- [ ] BIOS bootloader fix
- [ ] NVIDIA pacman hook fix
- [ ] `btop`/`lazygit` duplication cleanup
- [ ] Bluetooth auto-configuration
- [ ] Firewall pre-configuration
- [ ] Kernel selection in installer
- [ ] LUKS encryption support
- [ ] ISO size reduction (< 1 GB target)
- [ ] Automated ISO release pipeline

### Known Issues (carried forward)
| Issue | Impact | Status |
|---|---|---|
| Login banner shows `Linux` instead of `Aero Linux` | Cosmetic | Unfixed |
| Snapper create-config in arch-chroot | Snapper not configured during install | Workaround: first-boot init |
| System services untested (NetworkManager, PipeWire, yay) | Unknown validation status | Pending |
| Snapshot boot entry untested | Snapshot rollback unverified | Pending |
| BIOS bootloader install broken | BIOS installation unsupported | Unfixed |
| NVIDIA hook target incorrect | NVIDIA systems need manual fix | Unfixed |
| `btop`/`lazygit` duplicated in packages | Cosmetic | Unfixed |
| `snapper-boot.service` lacks `[Install]` section | Never enabled | Unfixed |

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

`test.sh` automatically discovers the newest ISO in `out/` — no daily script edits needed.

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

Aero Linux **v0.1.1-alpha "Aero Alpha"** has achieved its first successful desktop boot. The installed system now:

- Boots via Limine (kernel + initramfs on FAT32 ESP)
- Mounts Btrfs root filesystem
- Launches greetd → Hyprland → Waybar → Ghostty
- Provides Neovim, Zsh, starship, and terminal functionality
- Uses hyprpaper for wallpaper display (migrated from swaybg)

Development is now focused on:
1. Full system validation (NetworkManager, PipeWire, yay, Snapper, services)
2. Fix remaining Alpha bugs (login banner, empty home, snapshot boot entry)
3. Begin Vim Motion Philosophy integration
4. Alpha stabilization and polish

---

## START HERE NEXT SESSION

### Current State
- **Version**: v0.1.1-alpha ("Aero Alpha")
- **Status**: ALPHA — First successful desktop boot achieved
- **Boot**: ✅ Limine → kernel → greetd → Hyprland desktop
- **Desktop**: ✅ Waybar, Ghostty, Neovim working
- **Wallpaper**: ✅ Migrated to hyprpaper (pending rebuild verification)
- **test.sh**: ✅ ISO auto-discovery + `install --clean` support
- **Known Issues**: Login banner, service validation pending, Snapper arch-chroot workaround

### Next Session Goals
1. **Full system validation**: NetworkManager, PipeWire, yay, snapper, first-boot service
2. **Fix remaining bugs**: login banner (`PRETTY_NAME`), empty home directory investigation, snapshot boot entry
3. **Verify all services**: `systemctl --failed`, snapper lists, network, audio
4. **Begin Vim Motion Philosophy implementation**: home-row keybindings design
5. **Continue Alpha stabilization**

### Exact Commands to Run

```bash
# 1. Build the ISO
sudo bash build.sh

# 2. Fresh install (deletes old qcow2 + OVMF state)
bash test.sh install --clean

# 3. Boot installed system
bash test.sh boot
```

### Validation Commands (run inside installed system)
```bash
# Systemd services
systemctl --failed

# Snapper
snapper list
systemctl status snapper-boot

# Networking
ip a
ping archlinux.org

# Audio
wpctl status

# Package management
yay --version
sudo pacman -Syu

# Desktop
hyprctl version
pgrep hyprpaper

# User environment
ls -la ~
cat /etc/aero-firstboot-complete
cat /etc/os-release | grep PRETTY_NAME
```

### Testing Workflow

For **installer, partitioning, bootloader, or filesystem changes:**
```bash
bash test.sh install --clean   # fresh qcow2 + fresh OVMF_VARS
```

For **desktop, Hyprland, Waybar, themes, services, or application changes:**
```bash
bash test.sh install           # reuse existing qcow2 (fast iteration)
bash test.sh boot              # boot the installed system
```

### Known Pitfalls
- Stale OVMF_VARS can cause PXE fallthrough — use `install --clean` or `rm -f /tmp/OVMF_VARS.4m.fd`
- Old qcow2 data persists across `install` runs — use `install --clean` to start fresh
- Snapper `create-config` fails inside arch-chroot — workaround already in place
- BIOS boot path is broken — UEFI-only for now

---

## License

License to be determined.
