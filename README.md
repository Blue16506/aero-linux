# Aero Linux

**Version 0.1.1-alpha — codename "First Boot"**

A bootable and installable Hyprland distribution in Alpha development. Keyboard-first, Vim-motion philosophy.

> Current Status: **ALPHA — First usable Hyprland session achieved. Snapper (P1) root cause identified and fix implemented, awaiting ISO rebuild + QEMU verification. Audio alsa-utils (P2) and login branding (P3) remaining.**

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

### Milestone: v0.1.1-alpha — "First Boot"

The installed system boots successfully into a Hyprland desktop session with working terminal, Neovim, networking, yay, and hyprpaper wallpaper system. All core systemd services report healthy (0 failed units). Snapper (P1) root cause identified and fix implemented; awaiting ISO rebuild and QEMU verification.

#### Achievements (v0.1.1-alpha)
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
- ✅ Snapper root cause identified: installer pre-created `@snapshots`
- ✅ Architectural decision: Snapper owns `.snapshots` creation (Option A)
- ✅ Installer changes: removed `@snapshots` subvol + mount, added `snapper create-config` in chroot
- ✅ `snapper-boot.service` enabled during install

#### Known Issues (carried forward)
- ❌ **P1 — Snapper (IMPLEMENTED, awaiting verification)**: Code changes complete. Needs ISO rebuild + QEMU test to confirm `snapper list-configs` shows root/home, `btrfs subvolume show /.snapshots` succeeds.
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
| first-boot.service | ✅ Snapper init moved to installer — first-boot serves as fallback |
| Snapper | 🟡 fix implemented, awaiting ISO rebuild + QEMU verification |
| Snapshot boot entry | ⏳ pending |
| BIOS boot path | 🔴 broken (UEFI-only) |

---

## Known Bugs (Alpha)

### P1 — Snapper Not Initialized — **FIX IMPLEMENTED, AWAITING VERIFICATION**
- **Root cause found**: Installer pre-created `@snapshots` subvolume and mounted at `/.snapshots`. `snapper create-config /` failed because `/.snapshots` already existed. `/etc/snapper/configs/root` was never generated.
- **Architectural decision (Option A)**: Snapper owns `.snapshots` creation. Installer should not pre-create `@snapshots`.
- **Fix**: Removed `@snapshots` subvolume creation and mount from installer. `snapper -c root create-config /` and `snapper -c home create-config /home` now run inside `arch-chroot`. Aero config templates overlaid after creation. `snapper-boot.service` enabled.
- **Verification needed**: `sudo bash build.sh` → `bash test.sh install --clean` → `bash test.sh boot` → verify inside installed system.

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

### Priority 1 — Fix Snapper Integration — **IMPLEMENTED, AWAITING VERIFICATION**
- [x] Root cause identified: `@snapshots` pre-creation conflicts with Snapper
- [x] Architectural decision: Snapper owns `.snapshots` creation (Option A)
- [x] Removed `@snapshots` subvolume creation/mount from `aero-install`
- [x] `snapper create-config /` and `snapper create-config /home` now run in `arch-chroot`
- [x] Aero config templates overlaid after Snapper initialization
- [x] `snapper-boot.service` enabled during install
- [ ] **Verify with ISO rebuild + QEMU test**: `sudo bash build.sh && bash test.sh install --clean && bash test.sh boot`
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
|---|---|---|
| Snapper not initialized | System snapshots unavailable | IMPLEMENTED, awaiting verification |
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
* Create Btrfs subvolumes (@, @home, @cache, @log)
* Install the base system (pacstrap)
* Configure users, locale, timezone, keymap
* Build yay AUR helper
* Initialize Snapper (creates `/.snapshots` subvolumes, generates configs)
* Install Limine bootloader
* Enable services (greetd, NetworkManager, first-boot, snapper-boot)
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
- **Version**: v0.1.1-alpha ("First Boot")
- **Status**: ALPHA — First usable Hyprland session achieved
- **Snapper (P1)**: 🟡 fix implemented (removed `@snapshots` pre-creation, Snapper init in chroot), awaiting ISO rebuild + QEMU verification
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
sudo snapper -c root list              # Should show initial snapshots
snapper list                           # List all snapshots
systemctl --failed                     # All services healthy
```

### Testing Workflow
- **Installer/bootloader/filesystem changes**: `bash test.sh install --clean` (fresh qcow2 + OVMF)
- **Desktop/service changes**: `bash test.sh install` (reuse qcow2) + `bash test.sh boot`

### Known Pitfalls
- Stale OVMF_VARS causes PXE fallthrough — use `install --clean` or `rm -f /tmp/OVMF_VARS.4m.fd`
- Old qcow2 data persists — use `install --clean` to start fresh
- BIOS boot path broken — UEFI-only for now

---

## Session Summary — 2026-06-16

### What Was Discovered

**Snapper root cause identified**: The installer was creating the `@snapshots` Btrfs subvolume and mounting it at `/.snapshots` *before* Snapper ever ran. When `snapper -c root create-config /` later executed (in `aero-firstboot.service` on first boot), Snapper failed because `/.snapshots` already existed. Snapper expects to own `.snapshots` creation — it creates the subvolume itself via `create-config`. Because `create-config` never succeeded, `/etc/snapper/configs/root` was never generated, and Snapper remained completely unconfigured.

### Architectural Decisions

- **Option A adopted**: Snapper owns `.snapshots` creation. The installer no longer pre-creates `@snapshots`. Instead, `snapper -c root create-config /` and `snapper -c home create-config /home` run inside `arch-chroot` during installation, allowing Snapper to create `/.snapshots` and `/home/.snapshots` as nested subvolumes under `@` and `@home` respectively.
- **Btrfs subvolume layout simplified**: Installer now creates only `@`, `@home`, `@cache`, `@log`. Snapper creates nested `.snapshots` subvolumes via `create-config`.

### Files Changed (this session)

| File | Change |
|------|--------|
| `airootfs/usr/local/bin/aero-install` | Removed `btrfs subvolume create /mnt/@snapshots` (Phase 3). Removed `.snapshots` from `mkdir -p` and removed `mount ... subvol=@snapshots` (Phase 4). Added `snapper -c root create-config /`, `snapper -c home create-config /home`, config template overlay, and `systemctl enable snapper-boot` (Phase 8 chroot). |
| `README.md` | Updated achievements, known issues, roadmap, current state, session summary, handoff section. |
| `PROJECT_STATUS.md` | Updated status, achievements, in-progress items, P1 marked fixed, roadmap, start-here section, session summary. |
| `PROJECT_CONTEXT.md` | Updated status, known issues, definition of success, session summary, handoff section. |
| `TODO.md` | Updated project status, P1 marked fixed, roadmap, notes, added Snapper Fix section, session summary. |
| `TESTING.md` | Updated checkpoint, P1 fixed, removed stale arch-chroot workaround, updated test expectations, session summary. |

*(first-boot.sh unchanged — idempotent guards handle fallback)*

### Risks Remaining

1. **Unverified fix**: The Snapper code changes have NOT been tested with a fresh ISO build and QEMU install. The fix compiles logically but has not been validated end-to-end.
2. **`/.snapshots` directory collision**: If `pacstrap` or any base package creates a `/.snapshots` directory, Snapper's `btrfs subvolume create .snapshots` inside the chroot will fail. Mitigation: no Arch package is known to create this path.
3. **Snapper fstab handling**: `snapper create-config` appends `/.snapshots` and `/home/.snapshots` fstab entries. Must be compatible with `genfstab` output.
4. **Snapshot boot entry**: `/Aero Linux (snapshot)` in `limine.conf` uses `rootflags=subvol=@/.snapshots/X/snapshot` — `X` is a placeholder, must be replaced with actual snapshot number. Untested.

### Next-Session Checklist

1. **Build & test P1 Snapper fix:**
   ```bash
   sudo bash build.sh
   bash test.sh install --clean
   bash test.sh boot
   ```
2. **Verify inside installed system:**
   ```bash
   sudo snapper list-configs              # Expect: root + home
   sudo btrfs subvolume show /.snapshots  # Expect: valid btrfs subvolume
   sudo ls /etc/snapper/configs           # Expect: root + home files
   sudo systemctl status snapper-boot     # Expect: enabled
   sudo snapper -c root list              # Expect: initial snapshots
   systemctl --failed                     # Expect: 0
   ```
3. **If P1 passes:** Mark Snapper as VERIFIED across all docs. Proceed to P2.
4. **If P1 fails:** Revert or adjust the fix based on failure mode.
5. **P2 (Audio):** Add `alsa-utils` to `packages.x86_64`, rebuild ISO, test audio.
6. **P3 (Branding):** Update `/etc/os-release` PRETTY_NAME to `Aero Linux`.
7. **Vim Motion Philosophy:** Begin home-row navigation design.

---

## Handoff — Quickstart for a New OpenCode Session

### Project State
- **Repo**: Aero Linux — custom Arch Linux distribution
- **Version**: v0.1.1-alpha codename "First Boot"
- **Build command**: `sudo bash build.sh` (archiso, requires root)
- **QEMU test command**: `bash test.sh install --clean && bash test.sh boot`
- **ISO output**: `out/aero-linux-YYYY.MM.DD-x86_64.iso` (auto-discovered by test.sh)
- **All scripts**: Pure Bash, no Python. TUI via `/dev/tty`.

### What Works
- ISO builds and boots (UEFI via systemd-boot live, Limine installed)
- Full TUI installer (partitioning, pacstrap, chroot, bootloader, Snapper init)
- Hyprland desktop, Waybar, Ghostty, Neovim, wallpaper (hyprpaper)
- NetworkManager DHCP, yay AUR helper, PipeWire/WirePlumber active
- `systemctl --failed` = 0 (all services healthy)

### P1 — Snapper (Fix Implemented, Awaiting Verification)
- **Root cause**: Installer pre-created `@snapshots`. `snapper create-config /` failed because `/.snapshots` already existed.
- **Fix**: Removed `@snapshots` creation/mount from installer. `snapper -c root create-config /` + `snapper -c home create-config /home` now run in `arch-chroot`. Aero configs overlaid. `snapper-boot` enabled.
- **Verification needed**: Build ISO, `install --clean`, boot, run validation commands.

### P2 — Audio alsa-utils Missing
- PipeWire active but Dummy Output. `aplay` not found. Add `alsa-utils` to `packages.x86_64`.

### P3 — Login Banner Shows `Linux`
- `/etc/os-release` PRETTY_NAME needs `Aero Linux`.

### Key Conventions
- `aero-install`: `airootfs/usr/local/bin/aero-install` — TUI installer
- `first-boot.sh`: `airootfs/usr/share/aero/scripts/first-boot.sh` — post-install setup
- Desktop configs: `/usr/share/aero/configs/{hypr,waybar,ghostty,mako,wlogout,walker,zsh,snapper}/`
- Modular Hyprland: hyprland.conf sources monitors, input, binds, appearance, autostart, windowrules
- Btrfs subvolumes: `@`, `@home`, `@cache`, `@log`. Snapper creates nested `.snapshots` subvolumes.
- Snapper config templates: `airootfs/etc/snapper/config-templates/root` and `/home`
- ESP mounted at `/boot` (FAT32). Kernel/initramfs on ESP for Limine.
- Limine v12: `/Title` syntax, `boot():/vmlinuz-linux` kernel paths.
- Testing: `install --clean` for fresh state, `install` for fast iteration.
- Versioning: `v0.1.1-alpha`. Codename: "First Boot".
- All documentation files track the session log: `README.md`, `PROJECT_STATUS.md`, `PROJECT_CONTEXT.md`, `TODO.md`, `TESTING.md`.

---

## License

License to be determined.
