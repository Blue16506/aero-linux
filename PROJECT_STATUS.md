# Aero Linux — Project Status

**Version 0.1.1-alpha** — "First Boot"

Last updated: 2026-06-16 (End-of-day wrap — Snapper root cause identified and fix implemented)

Project status: **ALPHA — First usable Hyprland session achieved**

Reason: Installer works, bootloader works, desktop works, networking works, yay works, PipeWire/WirePlumber active, systemctl --failed = 0, wallpaper fixed, mouse/keyboard work, home directory created correctly. Snapper (P1) root cause identified and fix implemented — awaiting ISO rebuild + QEMU verification. Audio alsa-utils (P2) and login branding (P3) remaining.

Versioning: `Major.Minor.Patch` (e.g., `0.1.1-alpha`, `0.2.0-alpha`, `1.0.0`). All pre-1.0 versions carry the `-alpha` suffix.

---

## Milestone: v0.1.1-alpha — First Usable Hyprland Session

### Achievements (v0.1.1-alpha)
- ✅ ISO builds and boots (UEFI via systemd-boot)
- ✅ Interactive TUI installer (partitioning, subvolumes, pacstrap, arch-chroot)
- ✅ Btrfs filesystem with subvolumes (@, @home, @cache, @log) — Snapper manages `.snapshots`
- ✅ Limine UEFI bootloader operational (BOOTX64.EFI, limine.conf, /Title syntax)
- ✅ Kernel boots via `boot():/vmlinuz-linux`, initramfs loads correctly
- ✅ Root filesystem mounts (Btrfs `@` subvolume)
- ✅ greetd + tuigreet login manager functional
- ✅ Hyprland launches and renders in installed system
- ✅ Waybar status bar appears
- ✅ Ghostty terminal works
- ✅ Neovim functional
- ✅ Wallpaper system migrated from swaybg to hyprpaper (Hyprland-native)
- ✅ test.sh auto-discovers newest ISO — no daily date hardcode edits
- ✅ test.sh supports `install --clean` for fresh qcow2 + OVMF state
- ✅ NetworkManager DHCP + internet connectivity confirmed
- ✅ yay AUR helper installed and functional
- ✅ PipeWire + WirePlumber services active
- ✅ `systemctl --failed` = 0 (all services healthy)
- ✅ Mouse and keyboard input working
- ✅ Home directory created correctly with user files
- ✅ First usable Hyprland desktop session achieved
- ✅ Snapper root cause identified (installer pre-created `@snapshots` — Snapper couldn't own it)
- ✅ Architectural decision (Option A): Snapper owns `.snapshots` creation
- ✅ Installer changes: removed `@snapshots` subvol/mount, added `snapper create-config` in chroot
- ✅ `snapper-boot.service` enabled during install

### In Progress

**Current Phase: Alpha Stabilization**
- ✅ P1 Snapper — root cause found, fix implemented, awaiting ISO rebuild + QEMU verification
- P2 Audio alsa-utils — pending
- P3 Login branding — pending
- Vim Motion Philosophy integration — on deck
- Polish and UX improvements — backlog

---

## Known Bugs (Alpha)

### P1 — Snapper Not Initialized — **FIX IMPLEMENTED, AWAITING VERIFICATION**
- **Root cause**: Installer pre-created `@snapshots` subvolume and mounted at `/.snapshots`. `snapper create-config /` failed because `/.snapshots` already existed. `/etc/snapper/configs/root` was never generated.
- **Architectural decision (Option A)**: Snapper owns `.snapshots` creation. Installer should not pre-create.
- **Fix**: Removed `@snapshots` creation/mount from `aero-install`. `snapper -c root create-config /` and `snapper -c home create-config /home` run inside `arch-chroot`. Aero config overlaid after create-config. `snapper-boot.service` enabled.
- **Verification needed**: `sudo bash build.sh → bash test.sh install --clean → bash test.sh boot` then verify inside installed system.
- Snapshot boot entry (`/Aero Linux (snapshot)`) untested.

### P2 — Audio: alsa-utils Missing
- PipeWire and WirePlumber services are active.
- Default audio sink: `auto_null` (Dummy Output) — no real audio device.
- `aplay` not found — `alsa-utils` not packaged.
- RTKit, BlueZ, libcamera warnings present but expected/non-fatal in QEMU VM.
- **Fix**: Add `alsa-utils` to package list or configure PipeWire ALSA compatibility layer.

### P3 — Login Banner
- `tuigreet` displays `Linux` from `/etc/os-release` PRETTY_NAME — needs `Aero Linux`.

### Test Infrastructure
- `/tmp/OVMF_VARS.4m.fd` retains UEFI boot state across QEMU sessions — stale state can cause PXE fallthrough. Use `install --clean` or delete manually.
- `/tmp/aero-test-disk.qcow2` not overwritten on re-install — use `install --clean` to start fresh.

### Installer
- Limited error handling — no recovery or rollback path.
- BIOS bootloader install broken (quoted heredoc + missing `limine-install` binary in chroot).
- `set -euo pipefail` combined with EXIT trap can unmount `/mnt` on any error.

### Other
- NVIDIA GPU auto-detection pacman hook target incorrect (file path instead of package name).
- `btop`/`lazygit` duplicated in packages (cosmetic).

---

## Roadmap: Alpha Stabilization

### Priority 1 — Fix Snapper Integration — **IMPLEMENTED, AWAITING VERIFICATION**
- [x] Root cause identified: `@snapshots` pre-creation in installer conflicts with Snapper's own `create-config`
- [x] Architectural decision: Option A — Snapper owns `.snapshots` creation
- [x] Removed `@snapshots` subvolume creation and mount from `aero-install`
- [x] Added `snapper create-config /` and `snapper create-config /home` in chroot
- [x] Snapper configs overlaid with Aero templates
- [x] `snapper-boot.service` enabled during install
- [ ] Verify with ISO rebuild + QEMU: `sudo bash build.sh && bash test.sh install --clean && bash test.sh boot`
- [ ] Verify snapshot boot entry (`/Aero Linux (snapshot)`)

### Priority 2 — Fix Audio Stack
- [ ] Package `alsa-utils` (add to `packages.x86_64` or `desktop.packages`)
- [ ] Verify audio output: `speaker-test` or `pw-play`
- [ ] Investigate `auto_null` default sink configuration

### Priority 3 — Fix Login Branding
- [ ] Update `/etc/os-release` PRETTY_NAME to `Aero Linux`

### Priority 4 — Begin Vim Motion Philosophy Implementation
- [ ] Design home-row navigation scheme for Hyprland (Super + hjkl / vim-style)
- [ ] Document unified keybinding philosophy
- [ ] Implement consistent keybindings across Hyprland, Waybar, Ghostty, walker

### Priority 5 — Polish & UX Improvements
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

## START HERE NEXT SESSION

### Current State
- **Version**: v0.1.1-alpha ("First Boot")
- **Status**: ALPHA — First usable Hyprland session achieved
- **Snapper (P1)**: 🟡 root cause found, fix implemented — awaiting ISO rebuild + QEMU verification
- **Audio (P2)**: pending
- **Login (P3)**: pending

### Next-Session Checklist
1. **Build ISO and test Snapper fix:**
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
3. **If P1 passes:** Mark Snapper as VERIFIED. Proceed to P2 (alsa-utils).
4. **If P1 fails:** Revert or adjust fix based on failure mode.
5. **Then P3:** Login branding (`/etc/os-release` PRETTY_NAME).
6. **Then Vim Motion Philosophy:** Home-row navigation design.

### Build + Install + Boot
```bash
sudo bash build.sh                     # Build ISO
bash test.sh install --clean           # Fresh install (required for filesystem changes)
bash test.sh boot                      # Boot installed system
```

### Validation Commands (run inside installed system)
```bash
sudo snapper list-configs              # Snapper status
sudo btrfs subvolume show /.snapshots  # Subvolume validation
sudo ls /etc/snapper/configs           # Config files
sudo systemctl status snapper-boot     # Boot snapshot service
sudo snapper -c root list              # Initial snapshots
systemctl --failed                     # Service health
```

### Key Architecture Decisions
- ESP mounted at `/boot` (FAT32, kernel/initramfs on FAT for Limine compatibility)
- Limine v12 config uses `/Title` syntax (not `entry "Title"`)
- Kernel paths use `boot():/vmlinuz-linux` prefix
- **Snapper**: Option A adopted — Snapper owns `.snapshots` creation. Installer no longer pre-creates `@snapshots`.
- All scripts are pure Bash — zero Python dependencies
- TUI rendering goes to `/dev/tty`, return values to stdout, logs to stderr
- testing: `install --clean` for fresh state, `install` for fast iteration

---

## Session Summary — 2026-06-16

### What Was Discovered
- **Snapper root cause**: Installer pre-created `@snapshots` subvolume. `snapper create-config /` failed because `/.snapshots` already existed. `/etc/snapper/configs/root` was never generated.
- **Architectural decision**: Adopted Option A — Snapper owns `.snapshots` creation. Removed all `@snapshots` logic from installer. `snapper create-config /` now runs inside `arch-chroot`.
- **Installer changes**: Removed `btrfs subvolume create /mnt/@snapshots` (Phase 3). Removed `.snapshots` from mkdir and removed `mount ... subvol=@snapshots` (Phase 4). Added `snapper -c root create-config /`, `snapper -c home create-config /home`, config template overlay, and `systemctl enable snapper-boot` (Phase 8 chroot).

### Files Changed
- `airootfs/usr/local/bin/aero-install` — core fix (installer)
- `README.md`, `PROJECT_STATUS.md`, `PROJECT_CONTEXT.md`, `TODO.md`, `TESTING.md` — documentation

### Risks Remaining
1. Fix not tested end-to-end — needs ISO rebuild + QEMU install
2. `/.snapshots` directory collision possible if `pacstrap` creates the path
3. Snapshot boot entry (`/Aero Linux (snapshot)`) untested — `X` placeholder needs replacement

### Next-Session Checklist
1. `sudo bash build.sh`
2. `bash test.sh install --clean`
3. `bash test.sh boot`
4. Verify: `snapper list-configs`, `btrfs subvolume show /.snapshots`, `ls /etc/snapper/configs`, `systemctl status snapper-boot`, `snapper -c root list`
5. If P1 passes: mark VERIFIED, proceed to P2 (alsa-utils) then P3 (login branding) then Vim Motion Philosophy

---

## Handoff — Quickstart for a New OpenCode Session

### Project State
- **Repo**: Aero Linux — custom Arch Linux distribution, v0.1.1-alpha "First Boot"
- **Build**: `sudo bash build.sh` → `out/aero-linux-*.iso` (auto-discovered by test.sh)
- **Test**: `bash test.sh install --clean && bash test.sh boot`
- **Language**: Pure Bash (zero Python). TUI via `/dev/tty`.

### Status Summary
| Priority | Issue | Status |
|----------|-------|--------|
| P1 | Snapper not initialized | Fix implemented, awaiting verification |
| P2 | Audio alsa-utils missing | Pending |
| P3 | Login banner shows `Linux` | Pending |

### What Works
- ISO builds, boots, installer works, Hyprland desktop runs
- Networking, yay, systemd services all healthy
- Wallpaper (hyprpaper), mouse/keyboard, home directory

### Key Files
- `airootfs/usr/local/bin/aero-install` — installer (573 lines, all Bash)
- `airootfs/usr/share/aero/scripts/first-boot.sh` — post-install setup (194 lines)
- `airootfs/etc/systemd/system/snapper-boot.service` — boot snapshot service
- `airootfs/etc/snapper/config-templates/root` and `/home` — Snapper config templates
- `packages.x86_64` — ISO package list
- `build.sh` — ISO build wrapper
- `test.sh` — QEMU test helper

### Btrfs Layout
```
@          → /          (root subvolume, contains /.snapshots as nested subvolume)
@home      → /home      (home subvolume, contains /home/.snapshots as nested subvolume)
@cache     → /var/cache (excluded from snapshots)
@log       → /var/log   (excluded from snapshots)
```
Snapper creates `/.snapshots` and `/home/.snapshots` via `snapper create-config`, not the installer.

### Testing Conventions
- `install --clean`: fresh qcow2 + fresh OVMF_VARS (for filesystem/bootloader/installer changes)
- `install`: reuse existing qcow2 (for desktop/config/service changes, faster iteration)
- `boot`: boot the installed system in QEMU
