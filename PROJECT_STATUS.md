# Aero Linux — Project Status

**Version 0.3.0-pre** — "First Boot"

Last updated: 2026-06-17 (Snapper architecture finalized and verified on QEMU)

Project status: **ALPHA — First usable Hyprland session achieved**

Reason: Installer works, bootloader works, desktop works, networking works, yay works, PipeWire/WirePlumber active, systemctl --failed = 0, wallpaper fixed, mouse/keyboard work, home directory created correctly. Snapper (P1) verified — initialization deferred to aero-firstboot.service, working on QEMU with zero failed services. Audio alsa-utils (P2) and login branding (P3) remaining.

Versioning: `Major.Minor.Patch` (e.g., `0.3.0-pre`, `0.4.0-pre`, `1.0.0`). All pre-1.0 versions carry the `-pre` suffix.

---

## Milestone: v0.3.0-pre — First Usable Hyprland Session

### Achievements (v0.3.0-pre)
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
- ✅ Architectural decision: Snapper init deferred to aero-firstboot.service on first boot
- ✅ Installer changes: removed `snapper create-config` from chroot; copies config templates to /usr/share/aero/configs/snapper/; enables snapper-boot.service, snapper-cleanup.timer, snapper-timeline.timer
- ✅ first-boot.sh handles all Snapper initialization (create-config, subvolume creation, config overlay, initial snapshots) with idempotent guards
- ✅ Service ordering cycle fixed (removed `After=graphical.target` from aero-firstboot.service)
- ✅ Diagnostics added (ERR trap, phase logging, guarded non-critical operations)
- ✅ End-to-end Snapper verification on QEMU: configs, subvolumes, snapshots, zero failed services

### In Progress

**Current Phase: Alpha Stabilization**
- ✅ P1 Snapper — VERIFIED — deferred to first boot, working on QEMU, zero failed services
- P2 Audio alsa-utils — pending
- P3 Login branding — pending
- Vim Motion Philosophy integration — on deck
- Polish and UX improvements — backlog

---

## Known Bugs (Alpha)

### P1 — Snapper — **VERIFIED (deferred to first-boot.service)**
- **Root cause**: `snapper create-config` fails inside `arch-chroot` because the chroot lacks Btrfs kernel support and udev device nodes. This is a fundamental limitation, not a configuration issue.
- **Architectural decision**: Snapper initialization is deferred entirely to `aero-firstboot.service` on first boot. The installer no longer runs `snapper create-config` in the chroot.
- **Fix**: Installer now only installs snapper, copies Aero config templates to `/usr/share/aero/configs/snapper/`, enables `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer`. The first-boot script (`first-boot.sh`) handles all actual Snapper initialization (create-config, subvolume creation, config overlay, initial snapshots) with idempotent guards.
- **Verification**: ISO built, installed via QEMU, validated inside installed system — `snapper list-configs` (root + home), valid subvolumes, initial snapshots, `systemctl --failed` = 0.
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

### Priority 1 — Fix Snapper Integration — **VERIFIED**
- [x] Root cause identified: `snapper create-config` fails inside `arch-chroot` (no Btrfs kernel/udev support)
- [x] Architectural decision: Snapper init deferred to aero-firstboot.service on first boot
- [x] Removed `snapper create-config` from installer chroot
- [x] Installer copies Aero config templates to `/usr/share/aero/configs/snapper/`
- [x] Installer enables `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer`
- [x] first-boot.sh handles all Snapper init (create-config, subvolumes, config overlay, initial snapshots) with idempotent guards
- [x] **Verified with ISO rebuild + QEMU**: `sudo bash build.sh && bash test.sh install --clean && bash test.sh boot`
- [x] Service ordering cycle fixed (removed `After=graphical.target`)
- [x] Diagnostics added (ERR trap, phase logging, guarded non-critical ops)
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
- **Version**: v0.3.0-pre ("First Boot")
- **Status**: ALPHA — First usable Hyprland session achieved
- **Snapper (P1)**: ✅ VERIFIED — deferred to first boot, working on QEMU, zero failed services
- **Audio (P2)**: pending
- **Login (P3)**: pending

### Next Steps
1. **P2 (Audio):** Add `alsa-utils` to `packages.x86_64`, rebuild ISO, test audio via QEMU.
2. **P3 (Branding):** Update `/etc/os-release` PRETTY_NAME to `Aero Linux`.
3. **Vim Motion Philosophy:** Begin home-row navigation design.

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
sudo systemctl status snapper-cleanup.timer  # Cleanup timer
sudo systemctl status snapper-timeline.timer # Timeline timer
sudo snapper -c root list              # Initial snapshots
systemctl --failed                     # Service health
```

### Key Architecture Decisions
- ESP mounted at `/boot` (FAT32, kernel/initramfs on FAT for Limine compatibility)
- Limine v12 config uses `/Title` syntax (not `entry "Title"`)
- Kernel paths use `boot():/vmlinuz-linux` prefix
- **Snapper**: Initialization deferred to `aero-firstboot.service` on first boot. Installer only installs snapper, copies config templates, and enables systemd units. The first-boot script handles all Snapper initialization (create-config, subvolume creation, config overlay, initial snapshots) with idempotent guards.
- All scripts are pure Bash — zero Python dependencies
- TUI rendering goes to `/dev/tty`, return values to stdout, logs to stderr
- testing: `install --clean` for fresh state, `install` for fast iteration

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

### Risks Remaining
1. Snapshot boot entry (`/Aero Linux (snapshot)`) untested — `X` placeholder needs replacement.
2. `/.snapshots` directory collision if any package creates this path (no Arch package known to do so).

---

## Handoff — Quickstart for a New OpenCode Session

### Project State
- **Repo**: Aero Linux — custom Arch Linux distribution, v0.3.0-pre "First Boot"
- **Build**: `sudo bash build.sh` → `out/aero-linux-*.iso` (auto-discovered by test.sh)
- **Test**: `bash test.sh install --clean && bash test.sh boot`
- **Language**: Pure Bash (zero Python). TUI via `/dev/tty`.

### Status Summary
| Priority | Issue | Status |
|----------|-------|--------|
| P1 | Snapper not initialized | ✅ VERIFIED — deferred to first boot, working on QEMU |
| P2 | Audio alsa-utils missing | Pending |
| P3 | Login banner shows `Linux` | Pending |

### What Works
- ISO builds, boots, installer works, Hyprland desktop runs
- Networking, yay, systemd services all healthy
- Wallpaper (hyprpaper), mouse/keyboard, home directory
- **Snapper**: root + home configs, valid subvolumes, initial snapshots, zero failed services

### Key Files
- `airootfs/usr/local/bin/aero-install` — installer (579 lines, all Bash)
- `airootfs/usr/share/aero/scripts/first-boot.sh` — post-install setup (229 lines)
- `airootfs/etc/systemd/system/aero-firstboot.service` — first-boot service (no After/Wants)
- `airootfs/etc/systemd/system/snapper-boot.service` — boot snapshot service
- `airootfs/usr/share/aero/configs/snapper/root` and `home` — Snapper config templates
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
Snapper creates `/.snapshots` and `/home/.snapshots` via `snapper create-config` in aero-firstboot.service (Phase 1), not the installer.

### Testing Conventions
- `install --clean`: fresh qcow2 + fresh OVMF_VARS (for filesystem/bootloader/installer changes)
- `install`: reuse existing qcow2 (for desktop/config/service changes, faster iteration)
- `boot`: boot the installed system in QEMU
