# Aero Linux

**Version 0.3.0-pre — codename "First Boot"**

A bootable and installable Hyprland distribution in Alpha development. Keyboard-first, Vim-motion philosophy.

> Current Status: **ALPHA — First usable Hyprland session achieved. Snapper (P1) root cause identified and fixed — initialization successfully deferred to first boot, verified on QEMU, zero failed services. Audio alsa-utils (P2) and login branding (P3) remaining.**

Versioning: `Major.Minor.Patch` (e.g., `0.3.0-pre`, `0.4.0-pre`, `1.0.0`). Pre-1.0 versions use the `-pre` suffix.

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

### Milestone: v0.3.0-pre — "First Boot"

The installed system boots successfully into a Hyprland desktop session with working terminal, Neovim, networking, yay, and hyprpaper wallpaper system. All core systemd services report healthy (0 failed units). Snapper (P1) root cause identified and fixed — initialization deferred to first boot, verified on QEMU with zero failed services.

#### Achievements (v0.3.0-pre)
- ✅ ISO builds and boots (UEFI via systemd-boot)
- ✅ Interactive TUI installer (partitioning, subvolumes, pacstrap, arch-chroot)
- ✅ Btrfs filesystem with subvolumes (@, @home, @cache, @log) — Snapper manages `.snapshots`
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
- ✅ Snapper root cause identified: `snapper create-config` fails inside `arch-chroot` (no Btrfs kernel/udev support)
- ✅ Architectural decision: Snapper initialization deferred to first boot
- ✅ Installer changes: removed `snapper create-config` from chroot, keeps template copy + service enables
- ✅ `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer` enabled during install
- ✅ `aero-firstboot.service` ordering cycle fixed (removed `After=graphical.target`)
- ✅ `first-boot.sh` diagnostics: ERR trap + phase logging added
- ✅ Snapper initialization verified on QEMU: configs, subvolumes, snapshots, zero failed services

#### Known Issues (carried forward)
- ✅ **P1 — Snapper (VERIFIED)**: Snapper initialization deferred to `aero-firstboot.service` on first boot. Installer copies config templates and enables snapper services. Verified on QEMU — `snapper list-configs` shows root + home, subvolumes valid, initial snapshots created, `systemctl --failed` = 0.
- ❌ **P2 — Audio alsa-utils missing**: PipeWire/WirePlumber active but default sink is `auto_null` (Dummy Output). `aplay` not found. Need to package `alsa-utils`.
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
| first-boot.service | ✅ Snapper init deferred to first-boot.service — idempotent guards, verified on QEMU |
| Snapper | ✅ VERIFIED — root + home configs, valid subvolumes, initial snapshots, zero failed services |
| Snapshot boot entry | ⏳ pending |
| BIOS boot path | 🔴 broken (UEFI-only) |

---

## Known Bugs (Alpha)

### P1 — Snapper — **VERIFIED (DEFERRED TO FIRST BOOT)**
- **Root cause found**: `snapper create-config` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)` because chroot lacks Btrfs kernel support and udev device nodes.
- **Architectural decision**: Snapper initialization deferred to `aero-firstboot.service` on first boot. Installer no longer runs `snapper create-config` in chroot.
- **Fix**: Installer only installs snapper, copies Aero config templates to `/usr/share/aero/configs/snapper/`, enables `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer`. First-boot script handles actual snapper init (create-config, subvolume creation, config overlay, initial snapshots) with idempotent guards.
- **Verification**: ISO built, installed via QEMU, verified inside installed system — `snapper list-configs` shows root + home, subvolumes valid, initial snapshots created, `systemctl --failed` = 0.

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
- Snapper init deferred to `aero-firstboot.service` (first boot). Installer no longer runs `snapper create-config` in chroot.
- `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer` enabled during install.
- Snapshot boot entry (`/Aero Linux (snapshot)`) untested — depends on `aero-firstboot.service` completing.

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

### Priority 1 — Fix Snapper Integration — **VERIFIED**
- [x] Root cause identified: `snapper create-config` fails inside `arch-chroot` (no Btrfs kernel support)
- [x] Architectural decision: Snapper init deferred to `aero-firstboot.service` on first boot
- [x] Installer changes: removed `snapper create-config` from chroot, keeps template copy + service enables
- [x] Config templates copied to `/usr/share/aero/configs/snapper/` during install
- [x] `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer` enabled during install
- [x] First-boot script handles actual snapper init (create-config, subvolume creation, config overlay, initial snapshots)
- [x] Idempotent guards prevent re-initialization on subsequent boots
- [x] **Verified with ISO rebuild + QEMU test**: `sudo bash build.sh && bash test.sh install --clean && bash test.sh boot`
- [x] Service ordering cycle fixed (removed `After=graphical.target`)
- [x] Diagnostics added (ERR trap, phase logging, guarded non-critical ops)
- [ ] Verify snapshot boot entry (`/Aero Linux (snapshot)`)

### Priority 2 — Fix Audio Stack
- [ ] Package `alsa-utils` (add to `packages.x86_64` or `desktop.packages`)
- [ ] Test audio: `speaker-test -c 2 -l 1 -t wav` or `pw-play`
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
|---|---|---|---|
| Snapper initialization deferred to first boot | System snapshots unavailable until first-boot runs | VERIFIED — root + home configs working, zero failed services |
| Audio: alsa-utils missing / Dummy Output | No audio output | Pending packaging |
| Login banner shows `Linux` instead of `Aero Linux` | Cosmetic | Unfixed |
| Snapshot boot entry untested | Snapshot rollback unverified | Pending |
| BIOS bootloader install broken | BIOS installation unsupported | Unfixed |
| NVIDIA hook target incorrect | NVIDIA systems need manual fix | Unfixed |
| `btop`/`lazygit` duplicated in packages | Cosmetic | Unfixed |

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
* Create Btrfs subvolumes (@, @home, @cache, @log)
* Install the base system (pacstrap)
* Configure users, locale, timezone, keymap
* Build yay AUR helper
* Copy Snapper config templates to `/usr/share/aero/configs/snapper/` (used on first boot)
* Enable Snapper services + `aero-firstboot.service`
* Install Limine bootloader
* Enable services (greetd, NetworkManager, first-boot)
* Deploy desktop configurations

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

Aero Linux **v0.3.0-pre "First Boot"** has achieved its first successful desktop boot with stable Snapper integration. The installed system now:

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
- **Version**: v0.3.0-pre ("First Boot")
- **Status**: ALPHA — First usable Hyprland session achieved
- **Snapper (P1)**: ✅ VERIFIED — deferred to first boot, working on QEMU, zero failed services
- **Audio (P2)**: pending
- **Login (P3)**: pending

### Build + Install + Boot
```bash
sudo bash build.sh                     # Build ISO
bash test.sh install --clean           # Fresh install
bash test.sh boot                      # Boot installed system
```

### Validation Commands (run inside installed system)
```bash
sudo snapper list-configs              # Should show root + home
sudo btrfs subvolume show /.snapshots  # Should be a valid subvolume
sudo ls /etc/snapper/configs           # Should contain root + home
sudo systemctl status snapper-boot     # Should be enabled
sudo systemctl status snapper-cleanup.timer   # Should be enabled
sudo systemctl status snapper-timeline.timer  # Should be enabled
sudo snapper -c root list              # Should show initial snapshots
systemctl --failed                     # All services healthy (expect 0)
journalctl -u aero-firstboot.service -b  # Check completion log
```

### Testing Workflow
- **Installer/bootloader/filesystem changes**: `bash test.sh install --clean` (fresh qcow2 + OVMF)
- **Desktop/service changes**: `bash test.sh install` (reuse qcow2) + `bash test.sh boot`

### Known Pitfalls
- Stale OVMF_VARS causes PXE fallthrough — use `install --clean` or `rm -f /tmp/OVMF_VARS.4m.fd`
- Old qcow2 data persists — use `install --clean` to start fresh
- BIOS boot path broken — UEFI-only for now

---

## Session Summary — 2026-06-17

### What Was Accomplished

**Snapper architecture finalized and verified:**
1. **Root cause confirmed**: `snapper create-config` fails inside `arch-chroot` — the chroot lacks Btrfs kernel module and udev device nodes. This is a fundamental limitation, not a configuration issue.
2. **Architecture redesign**: Snapper initialization moved entirely from installer chroot to `aero-firstboot.service` on first boot of the installed system.
3. **Service ordering bug fixed**: `After=graphical.target` in the service unit created a soft ordering cycle with `WantedBy=multi-user.target`. Removed all `After=` and `Wants=` lines — the script manages its own network wait.
4. **Robustness improved**: Added ERR trap for exact failure line logging, phase boundary logging, and `|| true` guards on non-critical operations (wallpaper/config mkdir).
5. **End-to-end verification**: ISO rebuilt, installed via QEMU, booted, validated:
   - `snapper list-configs` → root (/) and home (/home) present
   - `/.snapshots` and `/home/.snapshots` → valid Btrfs subvolumes
   - Initial snapshots created and visible via `snapper -c root list`
   - `systemctl --failed` → 0 failed units
   - `aero-firstboot.service` → completes successfully, does not rerun after reboot

### Files Changed (this session)

| File | Change |
|------|--------|
| `airootfs/etc/systemd/system/aero-firstboot.service` | Removed `After=graphical.target`, `After=network-online.target`, `Wants=network-online.target`. Added `ExecStartPre`/`ExecStartPost` with logger diagnostics. |
| `airootfs/usr/share/aero/scripts/first-boot.sh` | Added ERR trap, phase boundary logging, `|| true` guards on non-critical mkdir operations, `exit 0` at end. |
| `airootfs/usr/local/bin/aero-install` | Fixed `INSTALL_LOG` unbound variable regression. |
| `README.md`, `PROJECT_CONTEXT.md`, `PROJECT_STATUS.md`, `TODO.md`, `TESTING.md` | Updated to reflect Snapper verified status, service fixes, final architecture. |

### Risks Remaining

1. **Snapshot boot entry untested**: `/Aero Linux (snapshot)` in `limine.conf` uses `rootflags=subvol=@/.snapshots/X/snapshot` — `X` placeholder needs replacement with actual snapshot number.
2. **`/.snapshots` directory collision**: If any package creates a `/.snapshots` directory, Snapper's `create-config` could fail. No Arch package is known to do this.

### Next Steps

1. **P2 (Audio)**: Add `alsa-utils` to `packages.x86_64`, rebuild ISO, test audio.
2. **P3 (Branding)**: Update `/etc/os-release` PRETTY_NAME to `Aero Linux`.
3. **Vim Motion Philosophy**: Begin home-row navigation design.

---

## Handoff — Quickstart for a New OpenCode Session

### Project State
- **Repo**: Aero Linux — custom Arch Linux distribution
- **Version**: v0.3.0-pre codename "First Boot"
- **Build command**: `sudo bash build.sh` (archiso, requires root)
- **QEMU test command**: `bash test.sh install --clean && bash test.sh boot`
- **ISO output**: `out/aero-linux-YYYY.MM.DD-x86_64.iso` (auto-discovered by test.sh)
- **All scripts**: Pure Bash, no Python. TUI via `/dev/tty`.

### What Works
- ISO builds and boots (UEFI via systemd-boot live, Limine installed)
- Full TUI installer (partitioning, pacstrap, chroot, bootloader, snapper service enables)
- Hyprland desktop, Waybar, Ghostty, Neovim, wallpaper (hyprpaper)
- NetworkManager DHCP, yay AUR helper, PipeWire/WirePlumber active
- `systemctl --failed` = 0 (all services healthy)
- **Snapper (P1)**: ✅ VERIFIED — deferred init to first boot, all configs/subvolumes/snapshots working, zero failed services

### P1 — Snapper (VERIFIED — Deferred to First Boot)
- **Root cause**: `snapper create-config` fails inside `arch-chroot` (no Btrfs kernel support). Chroot is not suitable for Snapper init.
- **Fix**: Snapper init moved to `aero-firstboot.service` on first boot. Installer only installs snapper, copies config templates, and enables snapper services.
- **Verification**: ISO built, installed via QEMU, validated inside installed system. See "Snapper Architecture" section above.

### P2 — Audio alsa-utils Missing
- PipeWire active but Dummy Output. `aplay` not found. Add `alsa-utils` to `packages.x86_64`.

### P3 — Login Banner Shows `Linux`
- `/etc/os-release` PRETTY_NAME needs `Aero Linux`.

### Key Conventions
- `aero-install`: `airootfs/usr/local/bin/aero-install` — TUI installer
- `first-boot.sh`: `airootfs/usr/share/aero/scripts/first-boot.sh` — post-install setup
- Desktop configs: `/usr/share/aero/configs/{hypr,waybar,ghostty,mako,wlogout,walker,zsh,snapper}/`
- Modular Hyprland: hyprland.conf sources monitors, input, binds, appearance, autostart, windowrules
- Btrfs subvolumes: `@`, `@home`, `@cache`, `@log`. Snapper creates nested `.snapshots` subvolumes on first boot.
- Snapper config templates: `airootfs/usr/share/aero/configs/snapper/` (copied during install, used on first boot)
- ESP mounted at `/boot` (FAT32). Kernel/initramfs on ESP for Limine.
- Limine v12: `/Title` syntax, `boot():/vmlinuz-linux` kernel paths.
- Testing: `install --clean` for fresh state, `install` for fast iteration.
- Versioning: `v0.3.0-pre`. Codename: "First Boot".
- All documentation files track the session log: `README.md`, `PROJECT_STATUS.md`, `PROJECT_CONTEXT.md`, `TODO.md`, `TESTING.md`.

---

## License

License to be determined.
