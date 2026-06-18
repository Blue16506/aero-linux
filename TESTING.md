# Aero Linux — Manual Installation Test

**Version 0.3.0-pre** — "First Boot"

> **Checkpoint: ALPHA — Snapper Verified on QEMU (2026-06-17)**
> System installs, boots, desktop works **in QEMU**. Snapper (P1) migrated to deferred first-boot init — **verified on QEMU**: configs, subvolumes, snapshots, zero failed services.
> ⚠️ Real hardware boot currently fails before reaching the `liveuser` session — under investigation.
> Pending: Audio alsa-utils (P2), Login branding (P3), Vim Philosophy (P4).

## Prerequisites

```bash
# Required packages
sudo pacman -S qemu-desktop edk2-ovmf

# Build the ISO
sudo bash build.sh
```

> **Note:** `test.sh` now auto-discovers the newest ISO in `out/` — daily date changes no longer require script edits. The testing workflow is resilient to version and date changes.

---

## Test 1 — Live Environment Boot

**QEMU Command (UEFI):**
```bash
bash test.sh live
```

**Expected outcomes:**
- [x] systemd-boot menu appears with "Aero Linux live environment"
- [x] Boot completes to greetd/tuigreet login screen
- [x] User `liveuser` with no password is shown
- [x] Login succeeds, shell opens with Aero ASCII art
- [x] `hyprland` starts (type `Hyprland` or let greetd launch it)
- [x] Waybar, wallpaper, and basic Hyprland keybindings work
- [x] Ghostty terminal opens (`Super + Enter`)
- [x] Neovim, Zsh, starship prompt all functional
- [x] No Hyprland deprecation warnings on startup (windowrules migrated to modern syntax)
- [x] No "started without start-hyprland" warning (uwsm integrated)

**QEMU Command (BIOS):**
```bash
bash test.sh live-bios
```

---

## Test 2 — Fresh Installation

**Status: VERIFIED (2026-06-13)** — Section updated to reflect current state.

**Step 1 — Create test disk and boot installer:**

For a **fresh install** (recommended for installer, partitioning, or bootloader changes):
```bash
bash test.sh install --clean
```

For a **fast re-install** (reuses existing qcow2 — desktop, service, or theme changes only):
```bash
bash test.sh install
```

Creates a 20G qcow2 disk and boots the ISO with it.

**Step 2 — Walk through the installer:**

| Prompt | Expected input | Notes |
|---|---|---|
| Timezone selector | Navigate to your region, press Enter | Arrow keys + Enter |
| Detect keyboard layout? | `Y` | Auto-detects from live env |
| Disk selection menu | Press Enter | Selects `/dev/vda` (only disk) |
| This will ERASE ALL DATA... | `y` | Confirms destructive operation |
| Hostname: | `aero-test` | |
| Username: | `tester` | |
| User password: | `test123` | Hidden input |
| Confirm password: | `test123` | |
| Reboot now? | `y` | After installation completes |

**Step 3 — Wait for installation:**
- `pacstrap` downloads ~3 GiB of packages (5–15 min depending on mirror)
- Script copies configs, runs `arch-chroot`, configures system
- yay AUR helper is built and installed during arch-chroot
- If `mkinitcpio` shows `ERROR: module not found: 'libcrc32c'` — cosmetic; correct hook list is written during install

**Verified outcomes:**
- [x] Partitioning completes without error (1 ESP + 1 Btrfs root)
- [x] Btrfs subvolumes created: `@`, `@home`, `@cache`, `@log`
- [x] Snapper config templates copied to `/usr/share/aero/configs/snapper/` — actual init deferred to first boot
- [x] Pacstrap completes without package conflicts
- [x] Fstab generated with UUID-based entries
- [x] Locale/timezone/keymap configured in chroot
- [x] User created and added to `wheel,audio,video,input,storage,network`
- [x] `sudoers.d/10-aero-user` created with `ALL=(ALL) ALL`
- [x] greetd configured with tuigreet + start-hyprland (uwsm wrapper)
- [x] NetworkManager, pipewire, wireplumber, greetd enabled
- [x] yay AUR helper built and installed
- [x] mkinitcpio initramfs generated
- [x] `aero-firstboot` service enabled
- [x] Limine bootloader: `BOOTX64.EFI` copied to ESP, `limine.conf` written at `/boot/EFI/BOOT/` with `boot():/` kernel paths
- [x] Snapper initialization deferred to `aero-firstboot.service` on first boot
- [x] Desktop configs deployed to user home
- [x] Installer reaches "Installation complete" and reboot prompt
- [x] ESP mounted at `/boot` instead of `/efi` (kernel/initramfs on FAT, readable by Limine)

**Note:** Snapper `create-config` previously failed inside `arch-chroot` because installer pre-created `@snapshots` subvolume. **FIXED**: Snapper init moved entirely to `aero-firstboot.service` (first boot). Installer now only installs snapper, copies config templates, and enables services. `first-boot.sh` Phase 2 handles all Snapper init with idempotent guards. Awaiting verification.

---

## Test 3 — Boot Installed System

**Status: Snapper verified on QEMU (2026-06-17)**

**QEMU Command:**
```bash
bash test.sh boot
```

**Prerequisite:** `bash test.sh install` or `bash test.sh install --clean` must have completed successfully.

**Step 1 — Boot the installed system:**
```bash
bash test.sh boot
```

**Expected outcomes:**
- [x] Limine bootloader menu appears with `/Aero Linux` entry
- [x] Default entry boots the installed kernel + initramfs
- [x] Root filesystem mounts (Btrfs `@` subvolume)
- [x] System reaches greetd/tuigreet login screen
- [x] Snapper verification (run inside installed system):
  - [x] `sudo snapper list-configs` shows `root` and `home`
  - [x] `sudo btrfs subvolume show /.snapshots` is a valid subvolume
  - [x] `sudo ls /etc/snapper/configs` contains `root` and `home`
  - [x] `sudo systemctl status snapper-boot` is enabled
  - [x] `sudo snapper -c root list` shows initial snapshots
- [x] `aero-firstboot.service` runs on first boot:
  - [x] Phase 1 (Snapper) — runs `create-config`, creates subvolumes, overlays config, creates initial snapshots (idempotent — skips if configs exist)
  - [x] Phase 2 — Network wait
  - [x] Phase 3 — AUR packages installed from `aur.packages` via yay
  - [x] Phase 4 — XDG user directories created
  - [x] Phase 5 — Hardware detection runs
  - [x] Phase 6 — Branding applied (wallpaper, theme)
  - [x] Phase 7 — Service disables itself, `/etc/aero-firstboot-complete` created
- [x] Hyprland desktop reaches graphical session
- [x] Waybar visible at top of screen
- [x] Ghostty terminal available (`Super + Enter`)
- [x] NetworkManager connected (DHCP via QEMU user NAT) — ✅ verified
- [x] Wallpaper displays (hyprpaper) — ✅ verified
- [x] `/etc/aero-firstboot-complete` exists (first-boot has run)
- [x] Reboot and re-test: first-boot does NOT run again

---

## Test 4 — Live-to-Installed Comparison

After a successful boot of the installed system, check:

| Component | Live ISO | Installed system |
|---|---|---|
| Bootloader | systemd-boot (UEFI) | Limine |
| Display manager | greetd + tuigreet | greetd + tuigreet |
| Compositor | Hyprland | Hyprland |
| Shell | zsh (liveuser/root) | zsh (tester) |
| Default user | liveuser (no pass) | tester (test123) |
| AUR packages | not installed | installed via yay at first boot |
| Desktop packages | not installed | installed via pacman at first boot |
| Snapper | not configured | configured for / and /home |
| Network | NetworkManager | NetworkManager |
| Audio | PipeWire | PipeWire |

---

## Failure Modes & Diagnosis

### ISO doesn't boot in QEMU
- Check that OVMF firmware exists: `ls /usr/share/edk2/x64/OVMF_CODE.4m.fd`
- Try BIOS mode: `bash test.sh live-bios`

### ISO doesn't boot on real hardware
- **Known limitation**: Aero Linux v0.3.0-pre is QEMU-verified only. Real hardware boot currently fails before reaching the `liveuser` session. This is under investigation.
- If testing on physical hardware, report failures with hardware specifications.

### Installer hangs at timezone selector
- The custom TUI reads from `/dev/tty` — ensure you're running QEMU with a display (not `-nographic`)
- Use graphical QEMU window or `-display curses`

### Pacstrap fails (no network)
- QEMU user-mode networking (`-nic user`) provides NAT — check that host has internet
- Guest should get 10.0.2.x address automatically
- Test with `ping archlinux.org` inside the live environment

### Bootloader not found after install
- Confirm Limine was installed to ESP: `find /mnt/boot/EFI/BOOT -name "*.EFI"` (inside live ISO, after install)
- Check that `/boot/EFI/BOOT/BOOTX64.EFI` and `/boot/EFI/BOOT/limine.conf` exist
- For UEFI: fallback boot path is `/EFI/BOOT/BOOTX64.EFI` — no NVRAM entry needed

### First-boot service fails
- Check journal: `journalctl -u aero-firstboot.service -b`
- Marker file may be missing: check `/etc/aero-installed`
- yay/AUR build failures are non-fatal (service continues)

### Snapper — Verified (2026-06-17)
- **Root cause**: `snapper create-config` fails inside `arch-chroot` because chroot lacks Btrfs kernel module and udev device nodes. This is a fundamental limitation.
- **Fix (final architecture)**: Snapper initialization moved entirely to `aero-firstboot.service` (first boot). Installer no longer runs `snapper create-config` in chroot. Instead, installer only installs snapper, copies Aero config templates to `/usr/share/aero/configs/snapper/`, and enables `snapper-boot.service`, `snapper-cleanup.timer`, `snapper-timeline.timer`. `first-boot.sh` Phase 1 handles all actual Snapper init: create-config, subvolume creation, config overlay, initial snapshots.
- **Service ordering**: `After=graphical.target` removed from service unit (caused cycle with `WantedBy=multi-user.target`).
- **Verification** (run inside installed system — all ✅ verified on QEMU):
  ```bash
  sudo snapper list-configs              # Expect: root + home
  sudo btrfs subvolume show /.snapshots  # Expect: valid btrfs subvolume
  sudo ls /etc/snapper/configs           # Expect: root + home files
  sudo systemctl status snapper-boot     # Expect: enabled
  sudo snapper -c root list              # Expect: initial snapshots
  journalctl -u aero-firstboot.service   # Check completion log
  systemctl --failed                     # Expect: 0
  ```

---

## Appendix: Known Bugs (Alpha)

### P1 — Snapper — **VERIFIED (Deferred to First Boot)**
- **Root cause**: `snapper create-config` fails inside `arch-chroot` (no Btrfs kernel/udev support).
- **Architectural decision**: Snapper init deferred to `aero-firstboot.service` on first boot for reliability. Installer only installs snapper, copies config templates, enables services.
- **Fix**: Moved all Snapper init to `first-boot.sh` Phase 1. Installer simplified. `first-boot.sh` handles create-config, subvolume creation, config overlay, initial snapshots with idempotent guards.
- **Verification**: ISO built, installed via QEMU, validated — root + home configs, valid subvolumes, initial snapshots, zero failed services.
- Snapshot boot entry (`/Aero Linux (snapshot)`) untested.

### P2 — Audio: alsa-utils Missing
- PipeWire + WirePlumber active but default sink is `auto_null` (Dummy Output).
- `aplay` not found — `alsa-utils` not packaged.
- RTKit/BlueZ/libcamera warnings present but expected/non-fatal in QEMU VM.
- **Fix**: Add `alsa-utils` to package list.

### P3 — Login Banner
- `tuigreet` displays `Linux` from `/etc/os-release` PRETTY_NAME — should show `Aero Linux`.

### OVMF Variable Persistence
- `/tmp/OVMF_VARS.4m.fd` retains UEFI boot state across QEMU sessions.
- Stale variables can cause PXE fallthrough.
- **Fix:** `bash test.sh install --clean` (deletes it automatically) or `rm -f /tmp/OVMF_VARS.4m.fd`

### Test Disk Reuse
- `/tmp/aero-test-disk.qcow2` is NOT overwritten on re-install — old install data persists.
- **Fix:** `bash test.sh install --clean` (deletes it automatically) or `rm -f /tmp/aero-test-disk.qcow2`

### Other Known Issues
- BIOS bootloader install broken (UEFI-only for now)
- NVIDIA GPU auto-detection pacman hook target incorrect
- `btop`/`lazygit` duplicated in packages (cosmetic)
- Limited installer error handling and no rollback path

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

### What Was Accomplished This Session
1. **Root cause confirmed**: `snapper create-config` fails inside `arch-chroot` — the chroot lacks Btrfs kernel module and udev device nodes.
2. **Architecture redesign**: Snapper initialization moved entirely to `aero-firstboot.service` on first boot.
3. **Service ordering bug fixed**: Removed `After=graphical.target` from service unit (caused cycle with `WantedBy=multi-user.target`).
4. **Robustness improved**: Added ERR trap, phase logging, `|| true` guards, `exit 0`.
5. **End-to-end verification**: ISO rebuilt, installed via QEMU, booted, validated — all Snapper features working, zero failed services.

### Files Changed (this session)
- `airootfs/etc/systemd/system/aero-firstboot.service` — removed `After=graphical.target`, added logger diagnostics
- `airootfs/usr/share/aero/scripts/first-boot.sh` — ERR trap, phase logging, guarded mkdir ops, `exit 0`
- `airootfs/usr/local/bin/aero-install` — fixed `INSTALL_LOG` unbound variable
- All 5 docs — updated to VERIFIED status, added Snapper Architecture section

### Next-Session Checklist
1. `sudo bash build.sh`
2. `bash test.sh install --clean`
3. `bash test.sh boot`
4. Verify: `snapper list-configs`, `btrfs subvolume show /.snapshots`, `ls /etc/snapper/configs`, `systemctl status snapper-boot`, `snapper -c root list`, `journalctl -u aero-firstboot.service -b` (check Phase 2)
5. If P1 passes → P2 (alsa-utils) → P3 (login branding) → Vim Motion Philosophy

---

## Handoff — Quickstart for a New OpenCode Session

### Project Identity
- **Aero Linux** v0.3.0-pre "First Boot" — custom Arch Linux distribution
- **Build**: `sudo bash build.sh` (archiso)
- **Test**: `bash test.sh install --clean && bash test.sh boot`
- **All Bash**: zero Python. TUI via `/dev/tty`.

### Status
| Triage | Issue | Status |
|--------|-------|--------|
| P1 | Snapper not initialized | ✅ VERIFIED — deferred to first boot, working on QEMU |
| P2 | Audio alsa-utils / Dummy Output | Pending (add to `packages.x86_64`) |
| P3 | Login banner shows `Linux` | Pending (update `/etc/os-release`) |
| H1 | Real hardware boot failure | ❌ Live ISO does not reach `liveuser` session on physical hardware |

### Btrfs Layout (Current)
```
@          → /          (Snapper creates /.snapshots as nested subvolume)
@home      → /home      (Snapper creates /home/.snapshots as nested subvolume)
@cache     → /var/cache
@log       → /var/log
```
No `@snapshots` — Snapper owns `.snapshots` creation via `create-config` on first boot (Phase 1).

### Key Architecture
- **ESP at `/boot`** — kernel/initramfs on FAT32 for Limine access
- **Limine v12**: `/Title` syntax, `boot():/vmlinuz-linux` kernel paths
- **Hyprland**: modular config (monitors, input, binds, appearance, autostart, windowrules)
- **Wallpaper**: hyprpaper (not swaybg)
- **Snapper**: deferred to `aero-firstboot.service` Phase 1 (not in installer chroot)
- **`aero-firstboot.service`**: no `After=`/`Wants=` ordering; ERR trap + phase logging for diagnostics
- **Testing**: `install --clean` for fresh state, `install` for fast iteration

### Verification (✅ verified on QEMU)
```bash
sudo snapper list-configs              # Expect: root + home
sudo btrfs subvolume show /.snapshots  # Expect: valid subvolume
sudo ls /etc/snapper/configs           # Expect: root + home
sudo systemctl status snapper-boot     # Expect: enabled
sudo snapper -c root list              # Expect: snapshots
journalctl -u aero-firstboot.service -b  # Expect: Phase 1 Snapper init OK
systemctl --failed                     # Expect: 0
```
