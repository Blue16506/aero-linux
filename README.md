# Aero Linux

A modern Arch-based Linux distribution focused on simplicity, performance, reliability, and a polished Hyprland desktop experience.

> Current Status: **Pre-alpha — Limine Config Syntax Fix — entries use `/Title` syntax**

---

## Features

* Arch Linux base
* Hyprland Wayland desktop
* greetd + tuigreet login manager
* Ghostty terminal
* Waybar status bar
* Btrfs filesystem with Snapper snapshots
* Limine bootloader (UEFI + BIOS)
* Interactive TUI installer
* Modular desktop configuration
* Custom Aero branding
* Reproducible ISO builds

---

## Screenshots

Screenshots coming soon.

---

## Project Goals

Aero Linux aims to provide:

* Easy installation
* Modern Wayland desktop experience
* Reliable system rollback
* Fast boot times
* Consistent design
* Modular configuration
* Simple maintenance
* Reproducible builds

---

## Technology Stack

| Component     | Technology        |
| ------------- | ----------------- |
| Base          | Arch Linux        |
| ISO Builder   | archiso           |
| Bootloader    | Limine            |
| Filesystem    | Btrfs             |
| Snapshots     | Snapper           |
| Desktop       | Hyprland          |
| Terminal      | Ghostty           |
| Status Bar    | Waybar            |
| Login Manager | greetd + tuigreet |
| Shell         | zsh               |
| Networking    | NetworkManager    |
| Audio         | PipeWire          |
| Bluetooth     | BlueZ             |

---

## Current Status

### Milestone: Limine Config Syntax Fix — entries use `/Title` syntax

The Limine v12.3.0 bootloader now sees valid menu entries and the boot menu appears. The only issue was config file syntax.

#### What Changed

* **Entry syntax**: `entry "Aero Linux"` → `/Aero Linux` (Limine v12 requires `/` at line start to mark a menu entry)
* **Removed entries**: `Reboot` and `Power Off` — `protocol: reboot` and `protocol: poweroff` are not valid in Limine v12 (supported protocols: `linux`, `limine`, `multiboot1/2`, `efi`, `efi_boot_entry`, `bios`)
* **Config location**: `/boot/EFI/BOOT/limine.conf` (UEFI fallback path — no NVRAM entry needed)
* **Kernel paths**: `boot():/vmlinuz-linux` (Limine's reference to the ESP partition root)

#### Validation History

| Fix | Status |
|---|---|
| ESP mounted at `/boot` (FAT32, Limine-readable) | ✅ verified |
| `BOOTX64.EFI` copied to `/EFI/BOOT/` on ESP | ✅ verified |
| `limine.conf` written alongside EFI binary | ✅ verified |
| OVMF PXE issue = stale `OVMF_VARS.4m.fd` | ✅ resolved |
| Limine loads and displays "Limine 12.3.0 (x86-64, UEFI)" | ✅ verified |
| Config syntax (`entry` → `/Title`) | ✅ fixed |
| Boot into installed Aero system | ⏳ pending |

#### Known Issues

* `protocol: reboot` / `protocol: poweroff` removed (not supported in Limine v12)
* BIOS bootloader path still broken (separate issue)
* Snapper 0.13.1 arch-chroot failure (workaround: first-boot init)

---

## Roadmap

### Installed System Boot Validation (Current Priority)

- [ ] `bash test.sh boot` — boot installed system from test disk
- [ ] Limine bootloader menu appears (UEFI fallback: `/EFI/BOOT/BOOTX64.EFI`)
- [ ] Installed system boots to greetd login
- [ ] Login with created user works
- [ ] `aero-firstboot.service` runs and completes
- [ ] Hyprland desktop starts
- [ ] NetworkManager connects (DHCP)
- [ ] PipeWire audio works
- [ ] yay AUR helper functional
- [ ] Snapper configs created on first boot
- [ ] Snapper snapshots created successfully
- [ ] First-boot service disables itself
- [ ] `/etc/aero-firstboot-complete` marker exists

| Issue | Impact | Status |
|---|---|---|---|
| Snapper 0.13.1 `create-config` fails inside `arch-chroot` | Snapper not configured during install | Workaround: first-boot init |
| BIOS bootloader installation broken (quoted heredoc + missing `limine-install`) | BIOS installation unsupported | Unfixed |
| BIOS live boot via syslinux untested | BIOS path unvalidated | Unfixed |
| NVIDIA GPU auto-detection pacman hook target incorrect | NVIDIA systems need manual fix | Unfixed |
| `btop`/`lazygit` duplicated in packages | Cosmetic | Unfixed |

### Future Goals (Post-Validation)

* Hyprland Lua migration for remaining configs
* BIOS bootloader fix
* NVIDIA pacman hook fix
* LUKS encryption support
* Plymouth boot splash
* Package selection during install
* Automated ISO releases
* Repository signing
* Theme system expansion

---

## Building the ISO

### Requirements

* Arch Linux host
* archiso
* limine

### Build

```bash
git clone https://github.com/Blue16506/aero-linux.git
cd aero-linux

sudo ./build.sh
```

The generated ISO will be placed in:

```text
out/
```

---

## Installation

Boot the Aero Linux ISO and run:

```bash
aero-install
```

The installer will:

* Detect boot mode
* Configure disks (GPT ESP + Btrfs)
* Create Btrfs subvolumes (@, @home, @cache, @log, @snapshots)
* Install the base system (pacstrap)
* Configure users, locale, timezone, keymap
* Build yay AUR helper
* Install Limine bootloader
* Enable services (greetd, NetworkManager, first-boot)
* Deploy desktop configurations
* Snapper is configured on first boot by aero-firstboot.service

---

## Directory Layout

```text
aero/
├── airootfs/
├── efiboot/
├── limine/
├── syslinux/
├── build.sh
├── packages.x86_64
├── profiledef.sh
├── PROJECT_CONTEXT.md
└── TODO.md
```

---

## Project Structure

Desktop configurations are modular:

```text
Hyprland
├── monitors.conf
├── input.conf
├── binds.conf
├── appearance.conf
├── autostart.conf
└── windowrules.conf
```

All desktop configurations live under:

```text
/usr/share/aero/configs/
```

and are deployed automatically during first boot.

---

## Development Status

Installation pipeline validated — installer completes, Limine installs, reboot reached. Development is now focused on:

* First-boot validation: snapper initialization, AUR packages, Hyprland, networking, audio
* Installed-system boot via `bash test.sh boot`
* BIOS boot validation
* Beta preparation after full workflow validation

---

## Contributing

Issues, bug reports, testing feedback, and pull requests are welcome.

Please test changes in a virtual machine before submitting major modifications.

---

## License

License to be determined.
