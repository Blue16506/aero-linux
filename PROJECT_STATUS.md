# Aero Linux — Project Status

**Version 0.1.1-alpha** — "Aero Alpha"

Last updated: 2026-06-14 (End-of-day wrap — first usable Hyprland session validated)

Project status: **ALPHA — First usable Hyprland session achieved**

Reason: Installer works, bootloader works, desktop works, networking works (DHCP + internet confirmed), yay works, PipeWire/WirePlumber active, systemctl --failed = 0, wallpaper fixed, mouse/keyboard work, home directory created correctly. Outstanding: Snapper initialization (P1), audio alsa-utils packaging (P2), login branding (P3).

Versioning: `Major.Minor.Patch` (e.g., `0.1.1-alpha`, `0.2.0-alpha`, `1.0.0`). All pre-1.0 versions carry the `-alpha` suffix.

---

## Milestone: v0.1.1-alpha — First Usable Hyprland Session

### Achievements
- ✅ ISO builds and boots (UEFI via systemd-boot)
- ✅ Interactive TUI installer (partitioning, subvolumes, pacstrap, arch-chroot)
- ✅ Btrfs filesystem with subvolumes (@, @home, @cache, @log, @snapshots)
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

### In Progress

**Current Phase: Alpha Stabilization**
- Investigate and fix Snapper initialization (P1)
- Package `alsa-utils` for audio (P2)
- Fix login banner branding (P3)
- Begin Vim Motion Philosophy integration
- Polish and UX improvements

---

## Known Bugs (Alpha)

### P1 — Snapper Not Initialized
- `/.snapshots` exists but `/etc/snapper/configs` is empty. `snapper list-configs` returns no configs.
- `snapper -c root create-config /` fails — hypothesis: `/.snapshots` is an **ordinary directory**, not a Btrfs subvolume.
- **Investigate**: `sudo btrfs subvolume show /.snapshots`, `mount | grep snapshots`, `file /.snapshots`.
- **If normal dir**: remove it safely, retry `sudo snapper -c root create-config /`.
- **If subvolume**: inspect first-boot.sh ordering and Snapper integration.
- `snapper-boot.service` lacks `[Install]` section — never enabled by any script.
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

### Priority 1 — Fix Snapper Integration
- [ ] Investigate `/.snapshots`: `btrfs subvolume show`, `mount | grep snapshots`, `file`
- [ ] If normal directory: remove it, `sudo snapper -c root create-config /`
- [ ] If subvolume: inspect first-boot.sh ordering and installer integration
- [ ] Verify `snapper list-configs`, `snapper list`, initial snapshot creation
- [ ] Fix `snapper-boot.service` (add `[Install]` section, enable it)
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
- **Version**: v0.1.1-alpha ("Aero Alpha")
- **Status**: ALPHA — First usable Hyprland session achieved
- **Boot**: ✅ Limine → kernel → greetd → Hyprland desktop
- **Desktop**: ✅ Waybar, Ghostty, Neovim working
- **Wallpaper**: ✅ hyprpaper — fixed and verified
- **Networking**: ✅ DHCP + internet confirmed
- **yay**: ✅ installed and functional
- **Services**: ✅ systemctl --failed = 0 (all healthy)
- **Audio**: 🟡 PipeWire active — Dummy Output (alsa-utils missing)
- **Snapper**: 🔴 not initialized — investigation needed

### Known Bugs (P1-P3)
- **P1 — Snapper**: `/.snapshots` exists but configs empty. Hypothesis: not a real Btrfs subvolume. Run `sudo btrfs subvolume show /.snapshots` to confirm.
- **P2 — Audio**: `alsa-utils` not packaged → `aplay` missing → Dummy Output. Add `alsa-utils` to packages.
- **P3 — Login**: `/etc/os-release` PRETTY_NAME shows `Linux` instead of `Aero Linux`.

### Next Session Goals
1. Finish Snapper investigation: `btrfs subvolume show /.snapshots`, `file /.snapshots`, `mount | grep snapshots`
2. Fix Snapper integration (remove normal dir if needed, `create-config`, verify)
3. Fix audio: package `alsa-utils`, verify `pw-play`
4. Fix login branding: update `/etc/os-release` PRETTY_NAME
5. Begin Vim Motion Philosophy implementation

### Investigation Commands (run inside installed system)
```bash
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
speaker-test -c 2 -l 1 -t wav         # Audio test
yay --version                          # AUR helper
hyprctl version                        # Hyprland compositor
pgrep hyprpaper                        # Wallpaper daemon
cat /etc/aero-firstboot-complete       # First-boot marker
findmnt /.snapshots                    # Snapshot mount status
```

### Key Architecture Decisions
- ESP mounted at `/boot` (FAT32, kernel/initramfs on FAT for Limine compatibility)
- Limine v12 config uses `/Title` syntax (not `entry "Title"`)
- Kernel paths use `boot():/vmlinuz-linux` prefix
- Snapper initialization deferred to first-boot service (may need re-architecture)
- All scripts are pure Bash — zero Python dependencies
- TUI rendering goes to `/dev/tty`, return values to stdout, logs to stderr
- `test.sh` supports `install --clean` for fresh qcow2 + OVMF_VARS
- `test.sh` auto-discovers newest ISO in `out/` (no daily date hardcode edits)
- Wallpaper: hyprpaper (Hyprland-native) replaces swaybg (Sway-only) for wallpaper display
