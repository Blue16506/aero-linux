# Aero Linux

A modern Arch-based Linux distribution focused on simplicity, performance, reliability, and a polished Hyprland desktop experience.

> Current Status: **Pre-alpha — Installation Pipeline Validated**

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

### Milestone: Full Installation Pipeline Validated

The Aero Linux installer now completes end-to-end in QEMU UEFI:

#### Live ISO
* ISO builds successfully (archiso)
* UEFI boot via systemd-boot
* greetd + tuigreet login with Aero branding
* Hyprland desktop fully functional (no deprecation warnings)
* Fresh pacman keyring initialized on every boot

#### Installation Pipeline
* Disk partitioning (GPT + ESP + Btrfs)
* Btrfs subvolumes (@, @home, @cache, @log, @snapshots)
* Subvolume mounting with compression
* Pacstrap package installation
* Locale, timezone, keymap configuration
* User creation with sudo and shell setup
* yay AUR helper built and installed
* mkinitcpio initramfs generation
* greetd display manager configuration
* Limine bootloader installation (UEFI)
* Desktop config deployment
* First-boot service installed

#### Key Fixes
* **Pacman keyring**: Added archiso-style boot-time keyring init (`pacman-init.service`) — fixes `pacstrap -K` failure
* **Password prompt**: Replaced `makepkg -si` (interactive sudo) with `makepkg -d` + root `pacman -U` — no password echo
* **Snapper workaround**: Moved `snapper create-config` from installer chroot to first boot — avoids `IO Error` in arch-chroot

---

## Roadmap

### First-Boot Validation (Current Priority)

- [ ] `bash test.sh boot` — boot installed system from test disk
- [ ] Limine bootloader menu appears
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

### Known Remaining Issues

* Snapper 0.13.1 `create-config` fails inside `arch-chroot` — root cause unknown (workaround: runs on first boot)
* BIOS bootloader installation broken (variable not expanded in quoted heredoc)
* BIOS live boot via syslinux untested
* NVIDIA GPU auto-detection pacman hook target incorrect
* `btop`/`lazygit` duplicated in packages

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
