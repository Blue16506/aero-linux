# Changelog

## v0.3.0-pre ("First Boot") — 2026-06-17

The first end-to-end **QEMU-verified** pre-release of Aero Linux.

### Highlights

- Deferred Snapper initialization to first boot
- Idempotent root and home Snapper setup
- Automatic creation of initial snapshots
- Fixed `aero-firstboot.service` ordering cycle
- Removed service self-termination (SIGTERM 15)
- Zero failed services after installation
- QEMU-verified end-to-end installation
- Physical hardware support is experimental — real hardware boot currently fails before reaching the liveuser session

### Release Status (QEMU)

| Component | Status |
|-----------|--------|
| Release Status | QEMU-VERIFIED |
| Installer | Working (QEMU) |
| First Boot Service | Working (QEMU) |
| Snapper | Working (QEMU) |
| Btrfs Snapshots | Working (QEMU) |
| QEMU Validation | Passed |
| Real hardware boot | ⚠️ NOT VERIFIED |
| Known Critical Bugs | None |

### What's New

- **Deferred Snapper initialization to first boot**: `snapper create-config` no longer runs inside `arch-chroot` (where Btrfs kernel/udev support is unavailable). All Snapper initialization happens on the booted system via `aero-firstboot.service`.
- **Idempotent Snapper setup**: `first-boot.sh` checks for existing configs before creating them. Multiple service re-executions are safe.
- **Automatic root and home snapshots**: Initial snapshots ("Initial Aero installation", "Initial Home snapshot") created on first boot.
- **Service ordering fixes**: Removed `After=graphical.target` from `aero-firstboot.service` — this created a soft ordering cycle with `WantedBy=multi-user.target` that prevented the service from ever starting.
- **Robustness improvements**: Added ERR trap for failure diagnostics, phase boundary logging, `|| true` guards on non-critical operations, explicit `exit 0`.
- **Zero failed services**: `systemctl --failed` returns 0 after installation and first boot.
- **QEMU-verified installation flow**: Full pipeline (ISO build → install → boot → Snapper verification) tested and validated.

### Files Changed

| File | Change |
|------|--------|
| `airootfs/etc/systemd/system/aero-firstboot.service` | Removed `After=graphical.target`, `After=network-online.target`, `Wants=network-online.target`. Added logger diagnostics. |
| `airootfs/usr/share/aero/scripts/first-boot.sh` | Added ERR trap, phase boundary logging, guarded mkdir ops, `exit 0`. Snapper init moved to Phase 1 (before network wait). |
| `airootfs/usr/local/bin/aero-install` | Fixed `INSTALL_LOG` unbound variable regression. Snapper init removed from chroot. |
| `packages.x86_64` | Added `snapper` package. |
| All documentation | Updated to reflect verified Snapper architecture, final service design. |

### Known Limitations

- **Real hardware boot**: Live ISO does not reach the `liveuser` session on physical hardware. QEMU-verified only.
- Audio: `alsa-utils` missing (P2)
- Login banner: `/etc/os-release` PRETTY_NAME shows `Linux` instead of `Aero Linux` (P3)
- Snapshot boot entry (`/Aero Linux (snapshot)`) untested
- BIOS bootloader install broken (UEFI-only)
- NVIDIA GPU pacman hook target incorrect
