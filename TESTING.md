# Aero Linux — Manual Installation Test

> **Checkpoint: Installation Pipeline Validated (2026-06-13)**
> The installer now completes end-to-end in QEMU UEFI: partitioning → pacstrap → arch-chroot → Limine → reboot.
> Test 1 is pre-checked. Tests 2–3 are the current focus. Test 4 deferred until beta.

## Prerequisites

```bash
# Required packages
sudo pacman -S qemu-desktop edk2-ovmf

# Build the ISO
sudo bash build.sh
```

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
- [x] Btrfs subvolumes created: `@`, `@home`, `@cache`, `@log`, `@snapshots`
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
- [x] Limine bootloader installed to ESP (UEFI)
- [-] Snapper config creation moved to first boot (workaround for arch-chroot failure)
- [x] Desktop configs deployed to user home
- [x] Installer reaches "Installation complete" and reboot prompt

**Note:** Snapper `create-config` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)` — root cause unknown. Workaround: initialization moved to `aero-firstboot.service` (first boot).

---

## Test 3 — Boot Installed System

**QEMU Command:**
```bash
bash test.sh boot
```

**Prerequisite:** `bash test.sh install` must have completed successfully.

**Step 1 — Boot the installed system:**
```bash
bash test.sh boot
```

**Expected outcomes:**
- [ ] Limine bootloader menu appears in QEMU window
- [ ] Default entry boots the installed kernel + initramfs
- [ ] System reaches greetd/tuigreet login screen
- [ ] Login with the user created during install (e.g. `tester` / `test123`)
- [ ] `aero-firstboot.service` runs on first boot:
  - [ ] Phase 2 — Snapper configuration:
    - [ ] `snapper -c root create-config /` succeeds
    - [ ] Aero snapper config template applied to root
    - [ ] `snapper -c home create-config /home` succeeds
    - [ ] Aero snapper config template applied to home
    - [ ] `snapper-boot.service` enabled
  - [ ] Phase 3 — AUR packages installed from `aur.packages` via yay
  - [ ] Phase 4 — Initial snapper snapshots created
  - [ ] Phase 5 — XDG user directories created
  - [ ] Phase 6 — Hardware detection runs
  - [ ] Phase 7 — Branding applied
  - [ ] Phase 8 — Service disables itself, `/etc/aero-firstboot-complete` created
- [ ] Hyprland desktop reaches graphical session
- [ ] Waybar visible at top of screen
- [ ] Ghostty terminal available (`Super + Enter`)
- [ ] NetworkManager connected (DHCP via QEMU user NAT)
- [ ] `snapper list` shows root and home configs
- [ ] Snapper snapshots exist (`snapper -c root list`)
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
- Confirm Limine was installed to ESP
- Check that `/efi/EFI/BOOT/BOOTX64.EFI` and `/efi/EFI/Limine/limine.conf` exist
- For UEFI: boot menu may need manual entry in UEFI firmware

### First-boot service fails
- Check journal: `journalctl -u aero-firstboot.service -b`
- Marker file may be missing: check `/etc/aero-installed`
- yay/AUR build failures are non-fatal (service continues)

### Snapper fails during installer (arch-chroot)
- Known issue: `snapper -c root create-config /` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`
- Workaround: Snapper initialization moved to `aero-firstboot.service` (first boot)
- Root cause still unknown — `/` is a valid Btrfs subvolume (inode 256), `/.snapshots` is valid, diagnostics pass

### Snapper fails on first boot
- Check `/etc/snapper/configs/root` exists after first-boot runs
- Ensure `@snapshots` subvolume is mounted at `/.snapshots`: `findmnt /.snapshots`
- Check journal: `journalctl -u aero-firstboot.service -b`
- Manual test: `sudo snapper -c root create-config /` (outside arch-chroot)
- Enable boot snapshots: `systemctl enable --now snapper-boot`
