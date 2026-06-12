# Aero Linux

A modern Arch-based Linux distribution focused on simplicity, performance, reliability, and a polished Hyprland desktop experience.

> Current Status: **Pre-alpha — Live Environment Validation Passed**

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

### Live Environment Validation Passed

The live ISO has been built and verified on UEFI systems:

#### Boot & Desktop
* ISO builds successfully
* UEFI boot works (systemd-boot)
* Archiso root filesystem mounts correctly
* greetd + tuigreet launches with Aero branding
* Passwordless `liveuser` login works
* Hyprland launches with Waybar, Ghostty, Neovim, Zsh
* Desktop is fully usable from the live ISO

#### Fixes Applied
* OVMF_VARS: corrected source from OVMF_CODE to OVMF_VARS template
* KEYMAP detection: replaced broken pipe-to-read with command substitution
* snapper-boot.service: added `[Install]` section with `WantedBy=multi-user.target`
* Snapper config overlay: custom settings applied after `create-config`
* Walker: removed from ISO packages (AUR-only); added `walker-bin` to aur.packages
* Hyprland `pseudotile`: removed (option deleted upstream in 0.55)
* Hyprland `vfr`: moved from `misc` to `debug` section (upstream change in 0.55)
* Ghostty `gpu-accelerated`: removed (option no longer exists; GPU always-on)

---

## Roadmap

### Installer & Installed-System Validation (Current Priority)

* [ ] Full installation via `aero-install` in QEMU VM
* [ ] First successful installed-system boot
* [ ] First-boot automation (AUR packages, config deployment, snapper)
* [ ] Networking (NetworkManager)
* [ ] Audio (PipeWire)
* [ ] Snapper snapshots on installed system
* [ ] Theming on installed system
* [ ] Walker launcher install from AUR

### Known Remaining Issues

* `windowrulev2` deprecation warnings in Hyprland — cosmetic, does not prevent desktop operation. Full Lua migration postponed until after install validation.
* BIOS bootloader installation broken (variable not expanded in quoted heredoc)
* NVIDIA GPU auto-detection pacman hook target incorrect
* snapper-boot home snapshot ExecStart uses shell operators (systemd passes as literal args)
* yay AUR build errors masked during install

### Future Goals (Post-Validation)

* Hyprland Lua migration (windowrules + other configs)
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
* Configure disks
* Create Btrfs subvolumes
* Install the base system
* Configure users
* Install Limine
* Configure Snapper
* Enable required services

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

Live environment validation is complete. Development is now focused on:

* Full installation testing via `aero-install`
* Installed-system boot and first-boot validation
* Networking, audio, theming, snapper, and AUR package testing
* Beta preparation after full workflow validation

---

## Contributing

Issues, bug reports, testing feedback, and pull requests are welcome.

Please test changes in a virtual machine before submitting major modifications.

---

## License

License to be determined.
