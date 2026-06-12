# Aero Linux — Manual Installation Test

> **Checkpoint: Live Environment Validation Passed**
> The live ISO has been built and verified. No Hyprland warnings remaining (windowrules migrated, uwsm integrated).
> Test 1 items below are pre-checked. Remaining tests (2–4) are the current focus.

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

**Step 1 — Create test disk and boot installer:**
```bash
bash test.sh install
```

This creates a 20G qcow2 disk and boots the ISO with it.

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
- `pacstrap` downloads ~3.2 GiB of packages (5–15 min depending on mirror)
- Script copies configs, runs `arch-chroot`, configures system
- If `mkinitcpio` shows `ERROR: module not found: 'libcrc32c'` — this is cosmetic, caused by the module name being `crc32c` not `libcrc32c` in the ISO's `mkinitcpio.conf`. It does not affect the installed system (correct hook list is written during install).

**Expected outcomes:**
- [ ] Partitioning completes without error (1 ESP + 1 Btrfs root)
- [ ] Btrfs subvolumes created: `@`, `@home`, `@cache`, `@log`, `@snapshots`
- [ ] Pacstrap completes without package conflicts
- [ ] Fstab generated with UUID-based entries
- [ ] Timezone symlink created in chroot
- [ ] User created and added to `wheel,audio,video,input,storage,network`
- [ ] `sudoers.d/10-aero-user` created with `ALL=(ALL) ALL`
- [ ] greetd configured with tuigreet + start-hyprland (uwsm wrapper)
- [ ] NetworkManager, pipewire, wireplumber, greetd enabled
- [ ] Snapper configs created for `root` and `home`
- [ ] `aero-firstboot` service enabled
- [ ] Limine bootloader installed to ESP

---

## Test 3 — Boot Installed System

**QEMU Command:**
```bash
bash test.sh boot
```

**Expected outcomes:**
- [ ] Limine bootloader menu appears
- [ ] Default entry boots the installed kernel + initramfs
- [ ] System reaches greetd/tuigreet login screen
- [ ] Login with `tester` / `test123`
- [ ] `aero-firstboot.service` runs:
  - [ ] Installs AUR packages from `aur.packages` via yay
  - [ ] Installs desktop packages via pacman
  - [ ] Deploys config files to `~/.config/`
  - [ ] Enables user-level systemd services
  - [ ] Snapper cleanup timeline enabled
  - [ ] Creates `/etc/aero-installed` marker
  - [ ] Disables itself (`ConditionPathExists=/etc/aero-installed`)
- [ ] Hyprland launches after first-boot completes
- [ ] Waybar visible at top of screen
- [ ] Ghostty terminal available (`Super + Enter`)
- [ ] NetworkManager connected (DHCP via QEMU user NAT)
- [ ] `snapper list` shows root and home configs
- [ ] Snapper snapshots exist

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

### Snapper fails
- Ensure Btrfs snapshots subvolume exists: `btrfs subvolume list /`
- Check `/etc/snapper/configs/root` exists
- Enable with: `systemctl enable --now snapper-timeline.timer`
