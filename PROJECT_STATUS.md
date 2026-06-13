# Aero Linux — Project Status

Last updated: 2026-06-13

---

## Completed

### Live Environment
- [x] ISO builds successfully (archiso)
- [x] UEFI boot via systemd-boot
- [x] greetd + tuigreet login with Aero branding
- [x] Hyprland desktop fully functional (no deprecation warnings)
- [x] Waybar, Ghostty, Neovim, Zsh, starship all working
- [x] Pacman keyring initialized on every live boot

### Installation Pipeline
- [x] Disk partitioning (GPT + ESP + Btrfs)
- [x] Btrfs subvolumes created (@, @home, @cache, @log, @snapshots)
- [x] Subvolume mounting with zstd compression
- [x] Pacstrap package installation completes
- [x] Locale, timezone, keymap configured in chroot
- [x] User created with groups and sudo access
- [x] yay AUR helper built from source (no password prompt)
- [x] mkinitcpio initramfs generated
- [x] greetd display manager configured
- [x] Limine bootloader: `BOOTX64.EFI` copied to ESP, `limine.conf` with `boot():/` kernel paths
- [x] Desktop configs deployed to user home
- [x] aero-firstboot.service enabled
- [x] Installer reaches "Installation complete" and reboot prompt
- [x] ESP mounted at `/boot` (kernel/initramfs on FAT, readable by Limine)

### Boot Architecture Fix (2026-06-13)
- [x] ESP mounted at `/boot` instead of `/efi` — kernel/initramfs on FAT32 for Limine compatibility
- [x] Removed broken `limine-install --efi /efi` (not available in chroot — `limine-mkinitcpio-hook` package not installed)
- [x] Direct binary copy: `cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI`
- [x] Config at `/boot/EFI/BOOT/limine.conf` with `boot():/vmlinuz-linux` kernel paths
- [x] Kernel/module paths fixed: previously `/boot/vmlinuz-linux` resolved relative to ESP root (wrong); now `boot():/vmlinuz-linux` correctly references ESP root
- [x] **Limine v12 config syntax fix**: `entry "Title"` → `/Title` — Limine's parser only recognizes `/` at line start as entry titles. `entry "..."` produced zero valid entries.
- [x] **Removed unsupported protocols**: `protocol: reboot` and `protocol: poweroff` removed (not in Limine v12's valid protocol list)
- [x] **OVMF_VARS fix**: stale `/tmp/OVMF_VARS.4m.fd` caused PXE fallthrough — deleting it restored boot to Limine
- [x] Pacman keyring: archiso-style boot-time initialization
- [x] Installer package installation: removed `pacstrap -K`
- [x] Password prompt: replaced `makepkg -si` with `makepkg -d` + `pacman -U`
- [x] Snapper: moved `create-config` from installer chroot to first boot
- [x] Disk selector: TUI rendering via `/dev/tty` instead of `>&2`

---

## In Progress

### First Boot Validation
- [ ] Rebuild ISO (`sudo bash build.sh`)
- [ ] Delete old artifacts: `rm -f /tmp/aero-test-disk.qcow2 /tmp/OVMF_VARS.4m.fd`
- [ ] Install: `bash test.sh install`
- [ ] Boot installed system: `bash test.sh boot`
- [ ] Limine menu appears with `/Aero Linux` entry
- [ ] System boots and reaches greetd login
- [ ] Login with created user
- [ ] aero-firstboot.service runs:
  - [ ] Snapper create-config for root and home
  - [ ] AUR packages installed via yay
  - [ ] Initial snapper snapshots created
  - [ ] Branding applied
  - [ ] Hardware detection
  - [ ] Service disables itself

### Desktop Validation
- [ ] Hyprland launches after first-boot
- [ ] Waybar visible
- [ ] NetworkManager connected
- [ ] PipeWire audio functional
- [ ] Snapper snapshots work
- [ ] Reboot idempotency

---

## Blocked

(None — boot architecture fix unblocks installed system boot testing)

---

## Known Issues

| Issue | Impact | Status |
|---|---|---|---|
| Snapper create-config fails in arch-chroot | Snapper not configured during install | Workaround: first-boot init |
| BIOS bootloader install broken (quoted heredoc + missing `limine-install`) | BIOS installation unsupported | Unfixed |
| BIOS live boot via syslinux untested | BIOS path unvalidated | Unfixed |
| NVIDIA hook target incorrect | NVIDIA systems need manual fix | Unfixed |
| `btop`/`lazygit` duplicated in packages | Cosmetic | Unfixed |
| `protocol: reboot`/`poweroff` not in Limine v12 | Reboot/poweroff entries removed | Fixed by removal |

---

## Next Milestone

**First successful boot into installed Aero system**
- Limine menu appears and `/Aero Linux` entry boots
- System reaches greetd login with created user
- First-boot service runs, Snapper initializes
- Hyprland desktop starts
- Network, audio, theming functional
- Reboot idempotency verified

After: beta preparation (BIOS boot fix, known issue cleanup, release pipeline).

---

## Updates

### 2026-06-13 — Limine v12 Config Syntax Fix

**Problem:** Limine 12.3.0 displayed "config file contains no valid entries" after boot architecture fix. The `entry "Title"` syntax is from GRUB/systemd-boot — Limine v12 requires `/Title` at line start.

**Root cause** (from `common/lib/config.c`):
- `config_get_entry_name()` scans for `/` characters to find menu entries
- The `/` must be at the start of a line (preceded by `\n` or at EOF)
- `entry "Aero Linux"` contains no `/` at all — scanner skips past
- The only `/` characters are inside `boot():/vmlinuz-linux` — rejected by the `if *(p-2) != '\n'` line-start guard
- Result: zero entries found

**Fix:** `entry "Aero Linux"` → `/Aero Linux`. Also removed `protocol: reboot` and `protocol: poweroff` entries (not in Limine v12 protocol list).

### 2026-06-13 — Boot Architecture Fix
