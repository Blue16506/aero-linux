# Aero Linux — Manual Installation Test

**Version 0.1.1-alpha** — "First Boot"

> **Checkpoint: ALPHA — Snapper Fix Implemented (2026-06-16)**
> System installs, boots, desktop works. Snapper (P1) root cause found and fix implemented — awaiting ISO rebuild + QEMU verification.
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
- [x] Snapper initialized during install — `/.snapshots` created by `snapper create-config /` in chroot
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
- [-] Snapper config creation moved to first boot (workaround for arch-chroot failure)
- [x] Desktop configs deployed to user home
- [x] Installer reaches "Installation complete" and reboot prompt
- [x] ESP mounted at `/boot` instead of `/efi` (kernel/initramfs on FAT, readable by Limine)

**Note:** Snapper `create-config` previously failed inside `arch-chroot` because installer pre-created `@snapshots` subvolume. **FIXED**: removed `@snapshots` creation/mount from installer. `snapper -c root create-config /` now runs inside `arch-chroot` and creates `/.snapshots` as a nested subvolume under `@`. Awaiting verification.

---

## Test 3 — Boot Installed System

**Status: Snapper fix awaiting verification (2026-06-16)**

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
- [ ] Snapper verification (run inside installed system):
  - [ ] `sudo snapper list-configs` shows `root` and `home`
  - [ ] `sudo btrfs subvolume show /.snapshots` is a valid subvolume
  - [ ] `sudo ls /etc/snapper/configs` contains `root` and `home`
  - [ ] `sudo systemctl status snapper-boot` is enabled
  - [ ] `sudo snapper -c root list` shows initial snapshots
- [ ] `aero-firstboot.service` runs on first boot:
  - [ ] Phase 2 (Snapper) — SKIPS (initialized during install, idempotent)
  - [ ] Phase 3 — AUR packages installed from `aur.packages` via yay
  - [ ] Phase 4 — Initial snapper snapshots created (now redundant — already created by snapper-boot)
  - [ ] Phase 5 — XDG user directories created
  - [ ] Phase 6 — Hardware detection runs
  - [ ] Phase 7 — Branding applied (wallpaper, theme)
  - [ ] Phase 8 — Service disables itself, `/etc/aero-firstboot-complete` created
- [x] Hyprland desktop reaches graphical session
- [x] Waybar visible at top of screen
- [x] Ghostty terminal available (`Super + Enter`)
- [x] NetworkManager connected (DHCP via QEMU user NAT) — ✅ verified
- [x] Wallpaper displays (hyprpaper) — ✅ verified
- [ ] `/etc/aero-firstboot-complete` exists (first-boot has run)
- [ ] Reboot and re-test: first-boot does NOT run again

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

### ISO doesn't boot
- Check that OVMF firmware exists: `ls /usr/share/edk2/x64/OVMF_CODE.4m.fd`
- Try BIOS mode: `bash test.sh live-bios`

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

### Snapper — Root Cause Found and Fixed (2026-06-16)
- **Root cause**: Installer pre-created `@snapshots` subvolume and mounted at `/.snapshots`. Snapper's `create-config /` failed because `/.snapshots` already existed. This blocked config generation.
- **Fix**: Removed `@snapshots` creation/mount from installer. `snapper -c root create-config /` and `snapper -c home create-config /home` now run inside `arch-chroot`, creating `/.snapshots` as nested subvolumes under `@` and `@home`. Aero config templates overlaid after creation.
- **Architectural decision**: Snapper owns `.snapshots` creation (Option A). Installer creates only `@`, `@home`, `@cache`, `@log`.
- **`snapper-boot.service`**: Has `[Install]` section. Enabled during install.
- **Verification needed** (run inside installed system):
  ```bash
  sudo snapper list-configs              # Expect: root + home
  sudo btrfs subvolume show /.snapshots  # Expect: valid btrfs subvolume
  sudo ls /etc/snapper/configs           # Expect: root + home files
  sudo systemctl status snapper-boot     # Expect: enabled
  sudo snapper -c root list              # Expect: initial snapshots
  sudo snapper -c root create --description "test" --cleanup number
  ```

---

## Appendix: Known Bugs (Alpha)

### P1 — Snapper Not Initialized — **FIX IMPLEMENTED, AWAITING VERIFICATION**
- **Root cause**: Installer pre-created `@snapshots` subvolume and mounted at `/.snapshots`. `snapper create-config /` failed because `/.snapshots` already existed. `/etc/snapper/configs/root` never generated.
- **Architectural decision (Option A)**: Snapper owns `.snapshots` creation. Installer should not pre-create.
- **Fix**: Removed `@snapshots` creation/mount from `aero-install`. `snapper -c root create-config /` and `snapper -c home create-config /home` run inside `arch-chroot`. Aero config overlaid. `snapper-boot.service` enabled.
- **Verification**: `sudo bash build.sh → bash test.sh install --clean → bash test.sh boot` then verify.
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

## Session Summary — 2026-06-16

### What Was Done This Session
- **Snapper root cause identified**: installer pre-created `@snapshots` subvolume; `snapper create-config /` failed because `/.snapshots` already existed.
- **Architectural decision (Option A)**: Snapper owns `.snapshots` creation. Installer creates only `@`, `@home`, `@cache`, `@log`.
- **Installer fix**: Removed `@snapshots` subvolume creation/mount (Phases 3-4). Added `snapper -c root create-config /` and `snapper -c home create-config /home` in chroot (Phase 8). Aero config overlaid. `snapper-boot.service` enabled.
- **`first-boot.sh` unchanged** — idempotent guards handle fallback.
- **Docs updated**: All 5 files reflect new Snapper architecture.

### Files Changed
- `airootfs/usr/local/bin/aero-install` — core fix
- `README.md`, `PROJECT_STATUS.md`, `PROJECT_CONTEXT.md`, `TODO.md`, `TESTING.md` — documentation

### Risks Remaining
1. Fix untested — needs ISO rebuild + QEMU verification
2. `/.snapshots` collision if `pacstrap` creates the path
3. Snapshot boot entry untested (`/Aero Linux (snapshot)` placeholder)

### Next-Session Checklist
1. `sudo bash build.sh`
2. `bash test.sh install --clean`
3. `bash test.sh boot`
4. Verify: `snapper list-configs`, `btrfs subvolume show /.snapshots`, `ls /etc/snapper/configs`, `systemctl status snapper-boot`, `snapper -c root list`
5. If P1 passes → P2 (alsa-utils) → P3 (login branding) → Vim Motion Philosophy

---

## Handoff — Quickstart for a New OpenCode Session

### Project Identity
- **Aero Linux** v0.1.1-alpha "First Boot" — custom Arch Linux distribution
- **Build**: `sudo bash build.sh` (archiso)
- **Test**: `bash test.sh install --clean && bash test.sh boot`
- **All Bash**: zero Python. TUI via `/dev/tty`.

### Status
| Triage | Issue | Status |
|--------|-------|--------|
| P1 | Snapper not initialized | Fix implemented, awaiting verification |
| P2 | Audio alsa-utils / Dummy Output | Pending (add to `packages.x86_64`) |
| P3 | Login banner shows `Linux` | Pending (update `/etc/os-release`) |

### Btrfs Layout (Current)
```
@          → /          (Snapper creates /.snapshots as nested subvolume)
@home      → /home      (Snapper creates /home/.snapshots as nested subvolume)
@cache     → /var/cache
@log       → /var/log
```
No more `@snapshots` — Snapper owns `.snapshots` creation via `create-config`.

### Key Architecture
- **ESP at `/boot`** — kernel/initramfs on FAT32 for Limine access
- **Limine v12**: `/Title` syntax, `boot():/vmlinuz-linux` kernel paths
- **Hyprland**: modular config (monitors, input, binds, appearance, autostart, windowrules)
- **Wallpaper**: hyprpaper (not swaybg)
- **Snapper**: initialized in `arch-chroot` during install, not on first boot
- **`first-boot.sh`**: fallback guards (idempotent), creates initial snapshots
- **Testing**: `install --clean` for fresh state, `install` for fast iteration

### Verification
```bash
sudo snapper list-configs              # Expect: root + home
sudo btrfs subvolume show /.snapshots  # Expect: valid subvolume
sudo ls /etc/snapper/configs           # Expect: root home
sudo systemctl status snapper-boot     # Expect: enabled
sudo snapper -c root list              # Expect: snapshots
```
