# Aero Linux — Project Status

**Version 0.1.1-alpha** — "Aero Alpha"

Last updated: 2026-06-14 (Alpha milestone — first successful desktop boot)

Project status: **ALPHA — First successful desktop boot achieved**

Reason: System installs via TUI installer, boots via Limine, launches Hyprland desktop with Waybar, Ghostty, Neovim, and hyprpaper wallpaper system. Wallpaper architecture migrated from swaybg to hyprpaper. test.sh supports ISO auto-discovery and `install --clean`.

Versioning: `Major.Minor.Patch` (e.g., `0.1.1-alpha`, `0.2.0-alpha`, `1.0.0`). All pre-1.0 versions carry the `-alpha` suffix.

---

## Milestone: v0.1.1-alpha — First Successful Desktop Boot

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
- ✅ First successful desktop boot achieved

### In Progress

**Current Phase: Alpha Stabilization**
- Complete system validation (NetworkManager, PipeWire, yay, Snapper, services)
- Fix remaining Alpha bugs (login banner, empty home, snapshot boot entry)
- Begin Vim Motion Philosophy integration
- Polish and UX improvements

---

## Known Bugs (Alpha)

### Desktop & Login
- **Linux PRETTY_NAME in login banner**: `tuigreet` displays `Linux` from `/etc/os-release` PRETTY_NAME — needs update to show `Aero Linux`.
- **Empty home directory**: Fresh user home may be missing XDG directories (Desktop, Downloads, etc.) — `xdg-user-dirs-update` runs in first-boot but behavior depends on XDG config presence.
- **Desktop wallpaper intentionally black until first-boot**: The wallpaper migration to hyprpaper is complete. Default background is black until `aero-theme apply catppuccin` runs during first-boot Phase 7.

### Snapper
- `snapper -c root create-config /` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`. Root cause unknown. Workaround: runs on first boot via `aero-firstboot.service`.
- `snapper-boot.service` lacks `[Install]` section — never enabled by any script; snapshot boot entry untested.

### Service Validation (Pending)
- **NetworkManager**: DHCP connectivity in QEMU user NAT untested.
- **PipeWire audio**: Audio output not yet verified.
- **yay AUR helper**: Package installation from AUR untested.
- **first-boot.service**: Full end-to-end run not yet validated across all 8 phases.

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

### Priority 1 — Complete System Validation
- [ ] Fix login banner: update `/etc/os-release` PRETTY_NAME to show `Aero Linux`
- [ ] Verify NetworkManager DHCP connectivity
- [ ] Verify PipeWire audio output
- [ ] Verify yay AUR helper installs packages
- [ ] Verify first-boot.service: Snapper create-config, AUR packages, snapshots, self-disable
- [ ] Verify snapper-boot.service enabled and functional
- [ ] Verify snapshot boot entry (`/Aero Linux (snapshot)`)
- [ ] Reboot idempotency (first-boot does NOT run again)
- [ ] Investigate empty home directory

### Priority 2 — Begin Vim Motion Philosophy Implementation
- [ ] Design home-row navigation scheme for Hyprland (Super + hjkl / vim-style)
- [ ] Document unified keybinding philosophy
- [ ] Implement consistent keybindings across Hyprland, Waybar, Ghostty, walker
- [ ] Keyboard-first workflow documentation

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
- **Status**: ALPHA — First successful desktop boot achieved
- **Boot**: ✅ Limine → kernel → greetd → Hyprland desktop
- **Desktop**: ✅ Waybar, Ghostty, Neovim working
- **Wallpaper**: ✅ hyprpaper (migrated from swaybg — pending rebuild verification)
- **test.sh**: ✅ ISO auto-discovery + `install --clean` support

### Next Session Goals
1. Full system validation (NetworkManager, PipeWire, yay, snapper, services)
2. Fix remaining bugs (login banner, empty home, snapshot boot entry)
3. Verify all services (`systemctl --failed`, snapper, network, audio)
4. Begin Vim Motion Philosophy implementation
5. Continue Alpha stabilization

### Exact Commands to Run
```bash
sudo bash build.sh                     # Build ISO
bash test.sh install --clean           # Fresh install
bash test.sh boot                      # Boot installed system
```

### Validation Commands (run inside installed system)
```bash
systemctl --failed                     # Systemd service health
snapper list                           # Snapper configs and snapshots
systemctl status snapper-boot          # Boot-time snapshot service
ip a                                   # Network interfaces
ping archlinux.org                     # Internet connectivity
wpctl status                           # PipeWire audio graph
yay --version                          # AUR helper
hyprctl version                        # Hyprland compositor
pgrep hyprpaper                        # Wallpaper daemon
ls -la ~                               # User home contents
cat /etc/aero-firstboot-complete       # First-boot marker
cat /etc/os-release | grep PRETTY_NAME # Login banner check
```

### Build & Test Commands
```bash
sudo bash build.sh                     # Build ISO
bash test.sh install --clean           # Fresh install (deletes old qcow2 + OVMF)
bash test.sh install                   # Fast re-install (reuse existing qcow2)
bash test.sh boot                      # Boot installed system
bash test.sh cleanup                   # Remove test disk only
```

### Key Architecture Decisions
- ESP mounted at `/boot` (FAT32, kernel/initramfs on FAT for Limine compatibility)
- Limine v12 config uses `/Title` syntax (not `entry "Title"`)
- Kernel paths use `boot():/vmlinuz-linux` prefix
- Snapper initialization deferred to first-boot service
- All scripts are pure Bash — zero Python dependencies
- TUI rendering goes to `/dev/tty`, return values to stdout, logs to stderr
- `test.sh` supports `install --clean` for fresh qcow2 + OVMF_VARS
- `test.sh` auto-discovers newest ISO in `out/` (no daily date hardcode edits)
- Wallpaper: hyprpaper (Hyprland-native) replaces swaybg (Sway-only) for wallpaper display
