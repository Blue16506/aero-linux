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
- [x] Limine bootloader installed to ESP (UEFI)
- [x] Desktop configs deployed to user home
- [x] aero-firstboot.service enabled
- [x] Installer reaches "Installation complete" and reboot prompt

### Key Fixes Applied
- [x] Pacman keyring: archiso-style boot-time initialization
- [x] Installer package installation: removed `pacstrap -K`
- [x] Password prompt: replaced `makepkg -si` with `makepkg -d` + `pacman -U`
- [x] Snapper: moved `create-config` from installer chroot to first boot
- [x] Disk selector: TUI rendering via `/dev/tty` instead of `>&2`

---

## In Progress

### First Boot Validation
- [ ] Fix `test.sh boot` — UEFI_ARGS unbound variable
- [ ] Boot installed system from QEMU test disk
- [ ] Limine menu appears and boots
- [ ] System reaches greetd login
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

- **Snapper 0.13.1 arch-chroot failure**: `snapper -c root create-config /` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`. Diagnostics prove `/` and `/.snapshots` are valid Btrfs subvolumes. Removing `/.snapshots` does not fix. Root cause unknown — possibly kernel/libbtrfsutil interaction inside chroot namespace. Workaround: initialization deferred to first boot via `aero-firstboot.service`.

---

## Known Issues

| Issue | Impact | Status |
|---|---|---|
| Snapper create-config fails in arch-chroot | Snapper not configured during install | Workaround: first-boot init |
| BIOS bootloader install broken (quoted heredoc) | BIOS installation unsupported | Unfixed |
| BIOS live boot via syslinux untested | BIOS path unvalidated | Unfixed |
| NVIDIA hook target incorrect | NVIDIA systems need manual fix | Unfixed |
| `btop`/`lazygit` duplicated in packages | Cosmetic | Unfixed |

---

## Next Milestone

**First-Boot Validation Complete**
- Installed system boots and reaches Hyprland desktop
- Snapper configured and creating snapshots
- AUR packages installed
- Network, audio, theming all functional
- First-boot service idempotent

After: beta preparation (BIOS boot, known issue cleanup, release pipeline).
