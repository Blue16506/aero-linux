# Aero Linux

A modern Arch-based Linux distribution focused on simplicity, performance, reliability, and a polished Hyprland desktop experience.

> Current Status: **Alpha**

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

### Alpha Milestone Achieved

Successfully verified:

* ISO builds successfully
* UEFI boot works
* Archiso root filesystem mounts correctly
* Live environment boots successfully
* greetd launches successfully
* Custom Aero login branding works
* Passwordless liveuser login works
* Hyprland launches successfully
* Installer launches successfully
* End-to-end live ISO workflow is functional

---

## Roadmap

### Beta Milestone

* Full installation testing
* First successful installed-system boot
* Networking validation
* Audio validation
* Power management testing
* Branding cleanup
* Hyprland configuration cleanup
* Timezone search improvements

### Future Goals

* LUKS encryption support
* Plymouth boot splash
* NVIDIA auto-detection
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

This project is currently in active development.

The Alpha milestone has been reached and development is now focused on:

* Installer validation
* Installed-system testing
* Branding polish
* Desktop refinement
* Beta preparation

---

## Contributing

Issues, bug reports, testing feedback, and pull requests are welcome.

Please test changes in a virtual machine before submitting major modifications.

---

## License

License to be determined.
