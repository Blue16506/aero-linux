# Aero Linux

**Version 0.1.1-alpha — codename "Aero Alpha"**

A bootable and installable Hyprland distribution in Alpha development. Keyboard-first, Vim-motion philosophy.

> Current Status: **ALPHA — First usable Hyprland session achieved. Installer works, bootloader works, desktop works, networking works, yay works, systemd services healthy. Snapper and audio alsa-utils pending.**

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

### Milestone: v0.1.1-alpha — First Usable Hyprland Session

The installed system now boots successfully into a Hyprland desktop session with working terminal, Neovim, networking, yay, and hyprpaper wallpaper system. All core systemd services report healthy (0 failed units). This marks Aero Linux's transition from proof-of-concept to functional and usable Alpha.

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
- ✅ NetworkManager DHCP + internet connectivity confirmed
- ✅ yay AUR helper installed and functional
- ✅ PipeWire + WirePlumber services active
- ✅ `systemctl --failed` = 0 (all services healthy)
- ✅ Mouse and keyboard input working
- ✅ Home directory created correctly with user files

#### Known Issues (carried forward)
- ❌ **P1 — Snapper not initialized**: `/.snapshots` exists but `/etc/snapper/configs` is empty. Hypothesis: `/.snapshots` may be an ordinary directory, not a Btrfs subvolume. Need `btrfs subvolume show /.snapshots` to confirm.
- ❌ **P2 — Audio alsa-utils missing**: PipeWire/WirePlumber active but default sink is `auto_null` (Dummy Output). `aplay` not found. Need to package `alsa-utils` or configure PipeWire ALSA compatibility.
- ❌ **P3 — Login banner shows `Linux`**: `/etc/os-release` PRETTY_NAME needs update to `Aero Linux`.
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
| Wallpaper display (hyprpaper) | ✅ verified |
| Networking (DHCP + internet) | ✅ verified |
| yay AUR helper | ✅ verified |
| PipeWire + WirePlumber | 🟡 active — default sink: Dummy Output (alsa-utils missing) |
| `systemctl --failed` | ✅ 0 failed units |
| Mouse and keyboard | ✅ verified |
| Home directory | ✅ verified — created correctly |
| first-boot.service | ⏳ pending investigation |
| Snapper | 🔴 not initialized — `/.snapshots` hypothesis: not a subvolume |
| Snapshot boot entry | ⏳ pending |
| BIOS boot path | 🔴 broken (UEFI-only) |

---

## Known Bugs (Alpha)

### P1 — Snapper Not Initialized
- `/.snapshots` exists but `/etc/snapper/configs` is empty. `snapper list-configs` returns no configs.
- `snapper -c root create-config /` fails — likely because `/.snapshots` is an **ordinary directory**, not a Btrfs subvolume.
- **Investigation**: Run `sudo btrfs subvolume show /.snapshots`, `mount | grep snapshots`, `file /.snapshots`.
- **If normal directory**: remove it, then `sudo snapper -c root create-config /`.
- **If subvolume**: inspect first-boot.sh ordering and Snapper integration in installer.
- Workaround: Snapper was supposed to initialize via `aero-firstboot.service` but appears to have missed this.

### P2 — Audio: alsa-utils Missing
- PipeWire and WirePlumber services are active.
- Default audio sink is `auto_null` (Dummy Output) — no real audio device detected.
- `aplay` command not found: `alsa-utils` is not packaged.
- RTKit, BlueZ, libcamera warnings present but expected/non-fatal in QEMU VM.
- **Fix**: Add `alsa-utils` to package list or configure PipeWire ALSA compatibility layer.

### P3 — Login Banner
- `tuigreet` displays `Linux` from `/etc/os-release` PRETTY_NAME instead of `Aero Linux`.

### Desktop
- **Desktop wallpaper intentionally black until first-boot**: hyprpaper migration complete. Wallpaper set by `aero-theme apply catppuccin` during first-boot Phase 7.

### Snapper
- `snapper -c root create-config /` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`.
- `snapper-boot.service` lacks `[Install]` section — never enabled by any script.
- Snapshot boot entry (`/Aero Linux (snapshot)`) untested.

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

---

## Roadmap: Alpha Stabilization

Phase goal: Stabilize the Alpha by completing system validation, fixing remaining bugs, and beginning Vim Motion Philosophy integration.

### Priority 1 — Fix Snapper Integration
- [ ] Investigate `/.snapshots`: `btrfs subvolume show /.snapshots`, `mount | grep snapshots`, `file /.snapshots`
- [ ] If normal directory: remove it, retry `sudo snapper -c root create-config /`
- [ ] If subvolume: inspect first-boot.sh ordering and Snapper integration
- [ ] Verify `snapper list-configs`, `snapper list`, initial snapshot creation
- [ ] Verify `snapper-boot.service` enabled and functional
- [ ] Verify snapshot boot entry (`/Aero Linux (snapshot)`)

### Priority 2 — Fix Audio Stack
- [ ] Verify `pacman -Q alsa-utils` — install if missing
- [ ] Test audio: `speaker-test` or `pw-play`
- [ ] Investigate `auto_null` default sink — configure PipeWire ALSA compatibility if needed

### Priority 3 — Fix Login Branding
- [ ] Update `/etc/os-release` PRETTY_NAME from `Linux` to `Aero Linux`

### Priority 4 — Begin Vim Motion Philosophy Implementation
- [ ] Design home-row navigation scheme for Hyprland (Super + hjkl / vim-style keys)
- [ ] Unified keybindings across launcher, file manager, terminal, TUI
- [ ] Keyboard-first workflows (mouse optional)
- [ ] System-wide motion consistency design document

### Priority 5 — Polish & UX Improvements
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
| Snapper not initialized | System snapshots unavailable | Investigating |
| Audio: alsa-utils missing / Dummy Output | No audio output | Pending packaging |
| Login banner shows `Linux` instead of `Aero Linux` | Cosmetic | Unfixed |
| first-boot.service not validated end-to-end | Snapper, AUR, snapshots unverified | Pending |
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

## CURRENTLY WORKING ON

### Current State
- **Version**: v0.1.1-alpha ("Aero Alpha")
- **Status**: ALPHA — First usable Hyprland session achieved
- **Boot**: ✅ Limine → kernel → greetd → Hyprland desktop
- **Desktop**: ✅ Waybar, Ghostty, Neovim working
- **Wallpaper**: ✅ hyprpaper — fixed and verified
- **Networking**: ✅ DHCP + internet verified
- **yay**: ✅ installed and functional
- **Services**: ✅ systemctl --failed = 0 (all healthy)
- **Audio**: 🟡 PipeWire active — Dummy Output (alsa-utils missing)
- **Snapper**: 🔴 not initialized — investigation needed
- **test.sh**: ✅ ISO auto-discovery + `install --clean` support
- **Known Issues**: Snapper (P1), Audio alsa-utils (P2), Login banner (P3)

### Known Bugs (P1-P3)
- **P1 — Snapper**: `/.snapshots` exists but configs empty. Hypothesis: not a real Btrfs subvolume. Run `sudo btrfs subvolume show /.snapshots` to confirm.
- **P2 — Audio**: `alsa-utils` not packaged → `aplay` missing → Dummy Output. Add `alsa-utils` to packages.
- **P3 — Login**: `/etc/os-release` PRETTY_NAME shows `Linux` instead of `Aero Linux`.

### Next Session Goals
1. **Finish Snapper root-cause investigation** — `btrfs subvolume show /.snapshots`, `file /.snapshots`, `mount | grep snapshots`
2. **Fix Snapper integration** — if normal dir, remove and `snapper -c root create-config /`
3. **Fix audio** — package `alsa-utils`, verify `pw-play` works
4. **Fix login branding** — update `/etc/os-release` PRETTY_NAME
5. **Begin Vim Motion Philosophy** — design home-row navigation scheme

### Exact Commands to Run First
```bash
# Investigate Snapper
sudo btrfs subvolume show /.snapshots
mount | grep snapshots
file /.snapshots
pacman -Q alsa-utils
cat /etc/os-release | grep PRETTY_NAME
```

### Build + Install + Boot
```bash
sudo bash build.sh                     # Build ISO
bash test.sh install --clean           # Fresh install
bash test.sh boot                      # Boot installed system
```

### Validation Commands (run inside installed system)
```bash
systemctl --failed                     # Systemd service health
snapper list-configs                   # Snapper configs
snapper list                           # Snapshots
systemctl status snapper-boot          # Boot-time snapshot service
ip a                                   # Network interfaces
ping archlinux.org                     # Internet connectivity
wpctl status                           # PipeWire audio graph
pacman -Q alsa-utils                   # Audio utilities
speaker-test -c 2 -l 1 -t wav         # Audio test (if alsa-utils installed)
yay --version                          # AUR helper
hyprctl version                        # Hyprland compositor
pgrep hyprpaper                        # Wallpaper daemon
cat /etc/aero-firstboot-complete       # First-boot marker
cat /etc/os-release | grep PRETTY_NAME # Login banner check
findmnt /.snapshots                    # Snapshot mount status
sudo btrfs subvolume show /.snapshots  # Snapshot subvolume status
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
