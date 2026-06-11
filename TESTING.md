# Aero Linux — QEMU Test Script

Quick way to test the ISO in a virtual machine without using real hardware.

## Prerequisites

```bash
sudo pacman -S qemu-desktop edk2-ovmf
```

## Usage

```bash
./test.sh <mode>
```

## Modes

| Command | What it does |
|---------|-------------|
| `./test.sh live` | Boot ISO in UEFI mode. Checks: boot menu, TTY, aero-install command |
| `./test.sh live-bios` | Same but BIOS mode (omit UEFI firmware) |
| `./test.sh install` | Creates a 20G virtual disk, boots ISO with both attached. Run `aero-install` inside and install to `/dev/vdb` |
| `./test.sh boot` | Boot the installed system from the virtual disk. Checks: Limine menu, greetd login, Hyprland desktop |
| `./test.sh cleanup` | Delete the virtual disk |

## Test Plan

### Phase 1 — Live ISO (`live`)

1. systemd-boot menu appears with "Aero Linux live environment"
2. Selecting it boots to a TTY
3. Aero ASCII art displayed with welcome message
4. `aero-install` command is available

### Phase 2 — Installation (`install`)

1. Run `aero-install`
2. Select `/dev/vdb` (20G disk)
3. Enter hostname, username, password
4. Wait for installation to complete
5. Say Y to reboot

### Phase 3 — Installed system (`boot`)

1. Limine menu shows "Aero Linux" entries
2. Selecting it boots to greetd+tuigreet
3. Login with the test user
4. Hyprland starts with Waybar + Ghostty terminal

## Tips

- **Release mouse:** `Ctrl+Alt+G`
- **Network**: Already enabled via `-nic user` (VM has internet)
- **Disk is persistent**: Until you run `cleanup`, you can reboot the same installation
- **BIOS vs UEFI**: Always test both modes before real hardware
