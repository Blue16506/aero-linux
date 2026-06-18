# Aero Linux

## Project Overview

A custom Arch Linux distribution focused on simplicity, reliability, performance, and a polished Hyprland desktop experience. Builds as a bootable ArchISO with an interactive TUI installer and minimal post-installation setup.

**Status:** ALPHA — First QEMU-verified Hyprland session achieved (v0.3.0-pre "First Boot"). ISO builds, UEFI boots, Hyprland desktop fully functional, installer works end-to-end (QEMU). Snapper (P1) migrated to deferred first-boot init — verified on QEMU, zero failed services. Real hardware boot currently fails before reaching the liveuser session. Audio alsa-utils (P2) and login branding (P3) pending.

## Core Goals

1. Easy installation via interactive TUI installer
2. Modern Wayland desktop using Hyprland
3. Reliable rollback with Btrfs + Snapper
4. Fast boot using Limine bootloader
5. Clean, modular configuration files
6. Consistent visual design across the system
7. Easy maintenance and extension
8. Reproducible ISO builds
9. Bash-first philosophy — no Python tooling, minimal dependencies

## Technology Stack

| Component | Choice |
|-----------|--------|
| Base | Arch Linux |
| ISO Builder | archiso |
| Bootloader (ISO) | systemd-boot (UEFI) / syslinux (BIOS) |
| Bootloader (installed) | Limine (UEFI + BIOS) |
| Filesystem | Btrfs with subvolumes |
| Snapshots | Snapper |
| Window Manager | Hyprland |
| Terminal | Ghostty |
| Status Bar | Waybar |
| Application Launcher | walker (installed post-boot via AUR) |
| Display Manager | greetd + tuigreet |
| Shell | zsh |
| Network | NetworkManager |
| Audio | PipeWire |
| Notifications | mako |
| Power Menu | wlogout |
| Screen Lock | hyprlock |
| Idle Daemon | hypridle |

## Directory Structure

```
aero/
├── .gitignore
├── PROJECT_CONTEXT.md              # This file
├── PROJECT_AUDIT.md                # Audit report
├── README.md                       # Project README
├── TESTING.md                      # Manual test checklist
├── TODO.md                         # Task tracking
├── build.sh                        # ISO build wrapper
├── test.sh                         # QEMU test helper
├── packages.x86_64                 # Packages in ISO
├── pacman.conf                     # Build-time pacman config
├── profiledef.sh                   # archiso profile definition
├── efiboot/                        # archiso UEFI boot files
│   ├── loader/loader.conf
│   └── loader/entries/01-aero-linux.conf
├── syslinux/                       # archiso BIOS boot files
│   ├── syslinux.cfg
│   ├── archiso_head.cfg
│   ├── archiso_sys.cfg
│   ├── archiso_sys-linux.cfg
│   ├── archiso_tail.cfg
│   └── splash.png
├── limine/                         # Limine bootloader binaries
│   ├── limine-bios.sys
│   ├── limine-uefi-cd.bin
│   └── BOOTX64.EFI
├── airootfs/                       # Overlay filesystem for ISO
│   ├── etc/
│   │   ├── greetd/config.toml
│   │   ├── limine.conf
│   │   ├── mkinitcpio.conf
│   │   ├── os-release
│   │   ├── pacman.d/mirrorlist
│   │   ├── pam.d/greetd
│   │   ├── snapper/config-templates/root
│   │   ├── snapper/config-templates/home
│   │   ├── sudoers.d/aero-installer
│   │   ├── systemd/system/
│   │   │   ├── aero-firstboot.service
│   │   │   └── snapper-boot.service
│   │   └── zsh/zshenv
│   ├── root/
│   │   ├── .automated_script.sh
│   │   ├── .config/starship.toml
│   │   ├── .zshrc
│   │   └── customize_airootfs.sh
│   └── usr/
│       ├── local/bin/
│       │   ├── aero-greeter
│       │   ├── aero-install
│       │   └── aero-theme
│       └── share/
│           ├── backgrounds/aero/default.jpg
│           └── aero/
│               ├── configs/
│               │   ├── ghostty/config
│               │   ├── hypr/
│               │   ├── mako/config
│               │   ├── snapper/root
│               │   ├── snapper/home
│               │   ├── walker/config.toml
│               │   ├── walker/themes/aero/style.css
│               │   ├── waybar/config.jsonc
│               │   ├── waybar/style.css
│               │   ├── wlogout/layout.json
│               │   ├── wlogout/style.css
│               │   └── zsh/
│               ├── packages/
│               │   ├── aur.packages
│               │   └── desktop.packages
│               ├── scripts/
│               │   ├── first-boot.sh
│               │   └── hardware-detect.sh
│               └── themes/
│                   └── catppuccin/
│                       ├── colors.toml
│                       └── wallpaper.jpg
└── out/                            # ISO build output
```

> `syslinux/` and `efiboot/` are standard archiso boot directories for the live ISO only.
> Limine is installed as the bootloader on the installed system during `aero-install`.

## Btrfs Subvolume Layout

```
/ (btrfs top-level)
├── @                  # Root subvolume (snapshotted, mounted at /)
│   └── .snapshots     # Snapper snapshot subvolume (created by snapper create-config on first boot)
├── @home              # Home subvolume (snapshotted, mounted at /home)
│   └── .snapshots     # Snapper snapshot subvolume (created by snapper create-config on first boot)
├── @cache             # Pacman cache (excluded from snapshots)
└── @log               # Log files (excluded from snapshots)
```

## Installation Flow

1. **Preflight** — Root check, UEFI/BIOS detection, network check
2. **Interactive prompts** — Timezone (custom TUI with search), keyboard layout, disk selection, hostname, username, password
3. **Partitioning** — GPT + ESP (UEFI) or msdos + boot (BIOS), Btrfs root
4. **Btrfs subvolumes** — `@`, `@home`, `@cache`, `@log` (Snapper creates `/.snapshots` and `/home/.snapshots` as nested subvolumes on first boot via `first-boot.sh`)
5. **Pacstrap** — Base system + desktop packages
6. **Fstab generation** — UUID-based mounts
7. **File copy** — Systemd services, snapper configs, first-boot scripts
8. **Chroot configuration** — Locale, timezone, hostname, users, mkinitcpio, greetd, services, first-boot service (Snapper init deferred to first boot)
9. **Limine install** — Deploy bootloader to ESP
10. **Desktop config deployment** — Copy configs to user home
11. **Finalize** — Write `/etc/aero-installed`, prompt reboot

## First Boot Flow

1. Triggered by `aero-firstboot.service` (ConditionPathExists: `/etc/aero-installed` + `!/etc/aero-firstboot-complete`)
2. **Phase 1 — Snapper initialization** (local filesystem, no network needed):
   - `snapper -c root create-config /` — creates `/.snapshots` subvolume + root config
   - `snapper -c home create-config /home` — creates `/home/.snapshots` subvolume + home config
   - Aero Snapper config templates overlaid from `/usr/share/aero/configs/snapper/`
   - Initial snapshots created: "Initial Aero installation" and "Initial Home snapshot"
   - Fully idempotent — skips if configs already exist
3. **Phase 2 — Network wait** (up to 60s)
4. **Phase 3** — Install AUR packages via yay (`aur.packages`)
5. **Phase 4** — Create XDG user directories
6. **Phase 5** — Run hardware detection
7. **Phase 6** — Apply branding (wallpaper, theme)
8. **Phase 7** — Write `/etc/aero-firstboot-complete`, disable service, exit 0

## Hyprland Architecture

Configuration is modular, sourced from `hyprland.conf`:

```
~/.config/hypr/
├── hyprland.conf      # Main config, sources all others
├── monitors.conf      # Monitor layout and resolution
├── input.conf         # Keyboard, touchpad, mouse
├── binds.conf         # Keybindings
├── appearance.conf    # Animations, gaps, borders, colors
├── autostart.conf     # Startup applications
└── windowrules.conf   # Window rules per application
```

## Theme System

```
/usr/share/aero/themes/<name>/
├── colors.toml        # Color palette (consumed by aero-theme)
├── hyprland.conf      # Hyprland appearance overrides (optional)
├── waybar.css         # Waybar style overrides (optional)
├── ghostty.conf       # Ghostty color overrides (optional)
├── mako.conf          # Notification config override (optional)
├── walker.css         # Walker theme CSS (optional)
├── starship.toml      # Prompt style overrides (optional)
└── wallpaper.jpg      # Desktop wallpaper
```

Only `catppuccin` is currently defined. `aero-theme apply <name>` copies theme files to `~/.config/`, sets wallpaper, and reloads affected services.

## Coding Standards

- Shell scripts use `bash` with `set -euo pipefail`
- Inputs are validated before use
- Failures are handled gracefully with meaningful error messages
- Status messages printed inline for user visibility
- Important operations logged to install log
- Scripts are idempotent whenever practical
- No unnecessary dependencies
- Readability and maintainability preferred over cleverness
- Pure bash — no Python, no external interpreters

## Current Status

### Verified Working

- ISO builds reproducibly via `build.sh`
- UEFI boot via systemd-boot (15s timeout boot menu)
- BIOS boot via syslinux
- Live environment boots to greetd/tuigreet login screen
- Login as `liveuser` (no password) succeeds
- Hyprland launches with Waybar, wallpaper
- Ghostty terminal, Neovim, Zsh all work in live session
- Desktop keybindings functional
- `aero-install` launches from live shell
- Timezone selector (custom TUI with search) works
- Full installation runs to completion in QEMU
- Limine installed to ESP with correct config
- Installed system boots to greetd login

**Applied Fixes (all validated on live ISO):**
1. OVMF_VARS: corrected from OVMF_CODE to OVMF_VARS.4m.fd template; removed `2>/dev/null` masking
2. KEYMAP detection: replaced pipe-to-read subshell with `$(KEYMAP=...)` command substitution
3. snapper-boot.service: added `[Install]` section with `WantedBy=multi-user.target`
4. Snapper config overlay: custom settings reapplied after `snapper create-config` to preserve ALLOW_GROUPS, timeline limits, NUMBER_MIN_AGE
5. Walker: removed from `packages.x86_64` (not in core/extra); `walker-bin` already in `aur.packages`
6. Hyprland pseudotile: removed `dwindle { pseudotile = true }` — option deleted from Hyprland 0.55
7. Hyprland vfr: moved from `misc` to `debug` section — wiki lists `debug.vfr`, not `misc.vfr`
8. Ghostty gpu-accelerated: removed `gpu-accelerated = true` — option removed from Ghostty; GPU is always-on by design
9. snapper-boot ExecStart: replaced shell operators `2>/dev/null || true` with systemd `-ExecStart` prefix
10. yay build errors: removed `2>/dev/null` masking from git clone and makepkg in aero-install
11. windowrules.conf: migrated all 14 rules from `windowrulev2` to modern `windowrule` syntax — eliminates all Hyprland deprecation warnings
12. greetd/tuigreet launcher: switched from direct `Hyprland` binary to `start-hyprland` (uwsm wrapper) — eliminates the "start-hyprland" warning
13. select_opt navigation: corrected escape sequence patterns from `A|[[`/`B|]` to `'[A'|k`/`'[B'|j`; changed post-increment `((sel++))` to pre-increment `((++sel))` to prevent `set -e` crash
14. select_opt Enter handling: break case now matches `$'\n'|$'\r'` (not just `""`); all UI output redirected to stderr; return value via `echo "$sel"` (stdout) avoids `set -e` trap on non-zero index
15. Installer log permission: moved `exec 2>"$INSTALL_LOG"` from line 11 to after root EUID check (line 174)
16. Zsh config deployment: changed `cp .../*` to `cp .../.` in customize_airootfs.sh to include dotfiles (`.zshrc`) in liveuser home — fixes zsh new-user wizard on first login
17. aero-install alias: added `alias aero-install='sudo /usr/local/bin/aero-install'` to aliases.zsh — fixes documented command without sudo
18. parted dependency: added `parted` to packages.x86_64 — installer uses parted for partitioning but it was not included in the live ISO
19. Disk selector rendering: moved all interactive TUI rendering to `/dev/tty` instead of `>&2` — fixes invisible menu and non-updating `>` marker in QEMU/Ghostty
20. Live ISO pacman keyring: added `etc-pacman.d-gnupg.mount`, `pacman-init.service`, and `multi-user.target.wants/pacman-init.service` — initializes a fresh, populated keyring on every live boot (matching official archiso releng)
21. Yay installation: replaced `makepkg -si` (build + install via sudo, triggers password prompt) with `makepkg -d` (build only, no sudo) + root `pacman -U` (install as root, no sudo) — eliminates interactive sudo password prompt during installer

### Fix 23 — Disk selector rendering via /dev/tty

**Root cause:**
Interactive TUI rendering inside command substitutions (`$(...)`) using inherited stderr (`>&2`) was unreliable in the QEMU/Ghostty environment. The selector logic worked internally, but the menu and `>` marker did not render correctly.

**Fix:**
Moved all interactive selector rendering to `/dev/tty`.

**Affected:**
- `select_opt()`
- `select_timezone()`
- `"Available disks:"` header

**Design rules:**
- Interactive TUI rendering → `/dev/tty`
- Selector return values → stdout
- Logs/errors → stderr

**Status:**
Disk selector now renders correctly.

**Validated:**
- `/dev/fd0` and `/dev/vda` are both visible.
- Arrow keys work.
- `j/k` navigation works.
- Enter selection works.
- Internal installer state matches the selected disk.

### Fix 24 — Yay installation without interactive sudo

**Root cause:**
`sudo -u "$USERNAME" makepkg -si --noconfirm` (inside `arch-chroot /mnt`) triggered an interactive sudo password prompt. `makepkg -si` internally calls `sudo pacman -U <pkgfile> --noconfirm` to install the built package. Since the sudoers entry for $USERNAME was `ALL=(ALL) ALL` (requires password), sudo prompted for authentication. The password characters appeared on screen due to sudo's getpass() interacting with /dev/tty inside the chroot.

**Fix:**
Split the build and install into two steps:
1. `makepkg -d --noconfirm` (build only, no internal sudo calls — `-d` skips dependency checking, no `-s`/`-i`)
2. `pacman -U <pkgfile> --noconfirm` (install as root directly, no sudo involved)

`makepkg -d` calls zero sudo commands. The resulting package is installed with root's `pacman -U`, which requires no password. The interactive sudo password prompt is eliminated entirely.

**Changed:**
- `aero-install:403-409`: replaced `makepkg -si` with `makepkg -d` + `pacman -U`

**Status:**
Yay is built as the normal user and installed as root. No sudoers file change needed. No NOPASSWD needed. No terminal stty traps needed.

### Known Issues (Resolved — Session 2026-06-13)

- **pacstrap provider prompts**: Installer prompts for provider selection during pacstrap: iptables vs iptables-legacy, mkinitcpio vs booster vs dracut, jack2 vs pipewire-jack. Installation eventually fails with "Errors occurred, no packages were upgraded."
- **BIOS bootloader installation broken**: `$LIMINE_FLAG` variable not expanded inside quoted heredoc in aero-install.
- NVIDIA GPU detection pacman hook target is incorrect — `hardware-detect.sh` line 32 uses invalid `Target` directive with file path.
- `btop` and `lazygit` duplicated in both `packages.x86_64` and `desktop.packages`
- `archinstall` on ISO is unused (~2MB but unnecessary)
- `base-devel` on ISO adds ~200-300MB unnecessarily
- Root password silently set to user password (aero-install line 244)
- `linux-firmware` is largest ISO contributor (~700MB)

## Definition of Success (v0.3.0-pre)

- [x] `mkarchiso` builds successfully
- [x] Produces a bootable ISO that boots to greetd+tuigreet
- [x] Live desktop (Hyprland, Waybar, Ghostty, Neovim, Zsh) fully functional — no deprecation warnings, clean uwsm launch
- [x] Interactive installer completes without errors (Snapper init deferred to first boot)
- [x] Installed system boots directly into Hyprland with Waybar
- [x] First-boot automation succeeds (idempotent guards, Snapper init in Phase 1)
- [x] Snapper snapshots work for root and home — verified on QEMU
- [x] Networking works on installed system
- [ ] Audio works on installed system (P2 — alsa-utils missing)
- [x] Theming works on installed system (wallpaper, Catppuccin theme)
- [ ] System is clean, maintainable, and well-documented

---

## Snapper Architecture (Final Design)

### Why Initialization Was Moved to First Boot

`snapper create-config` consistently failed inside `arch-chroot` during installation. The chroot environment lacks the Btrfs kernel module and udev device nodes required for Snapper to create nested subvolumes. Running `snapper create-config` in a chroot is fundamentally unreliable.

### Debugging Journey

1. **Initial hypothesis**: Installer pre-created `@snapshots` subvolume, conflicting with Snapper.
2. **Revised finding**: Even without pre-created subvolumes, `snapper create-config` fails inside `arch-chroot` with `IO Error (subvolume is not a btrfs subvolume)`.
3. **Root cause**: `arch-chroot` does not expose Btrfs kernel capabilities or udev device nodes needed by Snapper. The chrooted `snapper` binary cannot create Btrfs subvolumes.
4. **Resolution**: Deferred all Snapper initialization to `aero-firstboot.service` on first boot, where the full Btrfs-capable kernel and udev are available.
5. **Additional fixes**: Removed `After=graphical.target` from service unit (caused ordering cycle with `WantedBy=multi-user.target`), added `|| true` guards to non-critical operations, added diagnostics via `trap` and phase logging.

### Advantages of the Final Design

- **Simpler installer** — no `snapper create-config`, config overlay, or subvolume management during installation
- **More reliable Snapper setup** — runs on the booted system with full Btrfs kernel support and udev
- **Easier debugging** — phase boundary logging and ERR trap capture failures with exact line numbers
- **Idempotent initialization** — multiple re-executions of `aero-firstboot.service` are safe
- **Zero failed services** — `systemctl --failed` returns zero after all ordering and robustness fixes
- **Cleaner separation** — installer owns system installation; first-boot owns post-install configuration

---

## End of Session Summary — 2026-06-17

### What Was Accomplished This Session

**Snapper architecture finalized and verified:**
1. **Root cause confirmed**: `snapper create-config` fails inside `arch-chroot` — the chroot lacks Btrfs kernel module and udev device nodes. This is a fundamental limitation, not a configuration issue.
2. **Architecture redesign**: Snapper initialization moved entirely from installer chroot to `aero-firstboot.service` on first boot of the installed system.
3. **Service ordering bug fixed**: `After=graphical.target` in the service unit created a soft ordering cycle with `WantedBy=multi-user.target`. Removed all `After=` and `Wants=` lines — the script manages its own network wait.
4. **Robustness improved**: Added ERR trap for exact failure line logging, phase boundary logging, and `|| true` guards on non-critical operations (wallpaper/config mkdir).
5. **End-to-end verification**: ISO rebuilt, installed via QEMU, booted, validated:
   - `snapper list-configs` → root (/) and home (/home) present
   - `/.snapshots` and `/home/.snapshots` → valid Btrfs subvolumes
   - Initial snapshots created and visible via `snapper -c root list`
   - `systemctl --failed` → 0 failed units
   - `aero-firstboot.service` → completes successfully, does not rerun after reboot

### Files Changed (this session)
| File | Nature of Change |
|------|-----------------|
| `airootfs/etc/systemd/system/aero-firstboot.service` | Removed `After=graphical.target`, `After=network-online.target`, `Wants=network-online.target`. Added `ExecStartPre`/`ExecStartPost` with logger diagnostics. |
| `airootfs/usr/share/aero/scripts/first-boot.sh` | Added ERR trap, phase boundary logging, `|| true` guards on mkdir operations, `exit 0` at end. |
| `airootfs/usr/local/bin/aero-install` | Fixed `INSTALL_LOG` unbound variable regression. |
| `README.md`, `PROJECT_CONTEXT.md`, `PROJECT_STATUS.md`, `TODO.md`, `TESTING.md` | Updated to reflect Snapper verified status, service fixes, final architecture. |

### Current Status
| Priority | Issue | Status |
|----------|-------|--------|
| P1 | Snapper not initialized | ✅ VERIFIED — deferred to first boot, working on QEMU, zero failed services |
| P2 | Audio alsa-utils missing / Dummy Output | Pending |
| P3 | Login banner shows `Linux` | Pending |

### Risks
1. **Snapshot boot entry untested**: `/Aero Linux (snapshot)` placeholder `X` needs replacement with actual snapshot number.
2. **`/.snapshots` directory collision**: If any package creates a `/.snapshots` directory, Snapper's `create-config` could fail. No Arch package is known to do this.

### Next Steps
1. **Investigate real hardware boot failure** — diagnose `liveuser` session on physical hardware.
2. **P2 (Audio)**: Add `alsa-utils` to `packages.x86_64`, rebuild ISO, test audio.
3. **P3 (Branding)**: Update `/etc/os-release` PRETTY_NAME to `Aero Linux`.
4. **Vim Motion Philosophy**: Begin home-row navigation design.

---

## Handoff — Quickstart for a New OpenCode Session

### Project Identity
- **Name**: Aero Linux
- **Version**: v0.3.0-pre codename "First Boot"
- **Nature**: Custom Arch Linux distribution with Hyprland, Btrfs + Snapper, keyboard-first philosophy
- **Stack**: archiso → Limine bootloader → greetd/tuigreet → Hyprland → Waybar/Ghostty/Neovim

### Quick Commands
```bash
sudo bash build.sh                          # Build ISO (15-30 min)
bash test.sh install --clean                # Fresh QEMU install
bash test.sh boot                           # Boot installed system
bash test.sh live                           # Boot live ISO (no install)
```

### Known Limitation
- **Real hardware**: Live ISO does not reach the `liveuser` session on physical hardware. QEMU-verified only.

### P1 — Snapper (VERIFIED — Deferred to First Boot)
- Installer creates `@`, `@home`, `@cache`, `@log` only — NO `@snapshots`
- Installer installs snapper, copies Aero config templates to `/usr/share/aero/configs/snapper/`, enables services
- `first-boot.sh` Phase 1 handles all Snapper init: create-config, subvolume creation, config overlay, initial snapshots
- Idempotent guards in `first-boot.sh` — skips if configs already exist
- **Verified on QEMU**: `snapper list-configs` (root + home), `btrfs subvolume show /.snapshots` (valid), `systemctl --failed` (0)

### P2 — Audio (Pending)
- Add `alsa-utils` to `packages.x86_64`

### P3 — Login Branding (Pending)
- Change `PRETTY_NAME` in `/etc/os-release` from `Linux` to `Aero Linux`

### Architecture Essentials
- **ESP at `/boot`** (FAT32) — kernel/initramfs directly on ESP for Limine access
- **Btrfs**: `@` (root), `@home`, `@cache`, `@log`. Snapper creates nested `.snapshots` subvolumes on first boot via `first-boot.sh`.
- **Limine v12**: `/Title` syntax, `boot():/vmlinuz-linux` kernel paths
- **Desktop**: Modular Hyprland configs → `hyprland.conf` sources monitors/input/binds/appearance/autostart/windowrules
- **Wallpaper**: hyprpaper (Hyprland-native daemon, not swaybg)
- **All scripts Bash**: `/dev/tty` for TUI, stdout for return values, stderr for logs
- **Testing**: `test.sh install --clean` for fresh state (filesystem changes), `test.sh install` for fast iteration (desktop changes only)

### Key File Locations
| File | Purpose |
|------|---------|
| `airootfs/usr/local/bin/aero-install` | TUI installer (579 lines, pure Bash) |
| `airootfs/usr/share/aero/scripts/first-boot.sh` | First-boot setup (229 lines) |
| `airootfs/etc/systemd/system/snapper-boot.service` | Boot-time snapshot service |
| `airootfs/etc/snapper/config-templates/root` | Snapper root config template |
| `airootfs/etc/snapper/config-templates/home` | Snapper home config template |
| `packages.x86_64` | Packages included in ISO |
| `build.sh` | ISO build wrapper |
| `test.sh` | QEMU test automation |
| `airootfs/usr/share/aero/configs/snapper/root` | Aero Snapper config (deployed to installed system) |
| `airootfs/usr/share/aero/configs/snapper/home` | Aero Snapper config (deployed to installed system) |

### Docs Structure
- `README.md` — Project overview, achievements, known bugs, roadmap, session summary, handoff
- `PROJECT_STATUS.md` — Detailed status, achievements, bugs, roadmap, architecture, start-here, session summary
- `PROJECT_CONTEXT.md` — Full technical reference, directory structure, architecture, fix history, session logs
- `TODO.md` — Task tracking, known bugs, priorities, notes
- `TESTING.md` — Manual test checklist, failure modes, known bugs

### Installer Validation Progress

The installer was tested interactively in QEMU. Key milestones:

| Stage | Status |
|---|---|
| Installer launches from liveuser | ✅ |
| aero-install alias works (no manual sudo) | ✅ |
| Root escalation check | ✅ |
| Timezone selection | ✅ |
| Keyboard layout detection | ✅ |
| Disk selection (internal) | ✅ |
| Partitioning (parted) | ✅ |
| Filesystem creation (mkfs.btrfs, mkfs.fat) | ✅ |
| Btrfs subvolume creation | ✅ |
| Subvolume mounting | ✅ |
| pacstrap starts | ⚠️ |
| pacstrap completes | ❌ |

**Latest successful validation point:**
- Installer reaches package installation phase and downloads packages successfully.
- Disk partitioning succeeds.
- Filesystems are created.
- Subvolumes are mounted.
- pacstrap starts and downloads packages.

**Latest failure point:**
- Pacstrap package resolution triggers interactive provider-selection prompts:
  - iptables vs iptables-legacy
  - mkinitcpio vs booster vs dracut
  - jack2 vs pipewire-jack
- Installation eventually stops with: "Errors occurred, no packages were upgraded."
- Full installation has not yet completed.

### What Was Fixed This Session (Fixes 18-24)

1. **Fix 18 — select_opt Enter key and return value** (`aero-install:28-49`): Enter sent `$'\n'`/`$'\r'` in raw mode but break case only matched `""`. Also `return "$sel"` with `sel>0` returned non-zero exit code, triggering `set -e`. Fixed by adding newline/CR to case; redirecting UI to stderr; replacing `return "$sel"` with `echo "$sel"` (stdout) + command substitution in caller.

2. **Fix 19 — Installer log permission** (`aero-install:174`): `exec 2>"$INSTALL_LOG"` was at line 11, before the root EUID check at line 173. Non-root users got a permission denied error before seeing the "must be run as root" message. Moved after the root check.

3. **Fix 20 — Missing .zshrc in liveuser home** (`customize_airootfs.sh:63`): `cp .../*` skips dotfiles. Changed to `cp .../.` so `.zshrc` is copied into liveuser home, preventing zsh new-user configuration wizard on first login.

4. **Fix 21 — aero-install alias for liveuser** (`aliases.zsh:26`): Added `alias aero-install='sudo /usr/local/bin/aero-install'` so the documented command works without typing `sudo`.

5. **Fix 22 — Missing parted dependency** (`packages.x86_64:15`): Installer uses `parted` for partitioning but it was not listed in packages.x86_64. Added to the "Installer & boot" section.

6. **Fix 23 — Disk selector rendering via /dev/tty** (`aero-install:33,35,45,47,216`): Interactive TUI output using `>&2` was unreliable inside `$(...)` subshells. Changed all selector rendering to write directly to `/dev/tty` instead of `>&2`. Fixes the invisible menu and non-updating `>` marker.

7. **Fix 24 — Yay installation without interactive sudo** (`aero-install:404-408`): `sudo -u "$USERNAME" makepkg -si --noconfirm` triggered an interactive sudo password prompt because `makepkg -i` internally calls `sudo pacman -U`. Replaced with `makepkg -d --noconfirm` (build only, no internal sudo calls) + `pacman -U ... --noconfirm` (install as root, no sudo). Eliminates the password prompt without changing the sudoers file or adding NOPASSWD.

### Current Blocker

1. **PRIORITY 1 — pacstrap provider prompts**: `pacstrap` prompts for interactive provider selection (iptables vs iptables-legacy, mkinitcpio vs booster vs dracut, jack2 vs pipewire-jack). Arch Linux recently added these as "virtual" providers that require explicit choice. The installation is non-interactive during pacstrap, causing failure with "Errors occurred, no packages were upgraded." Fix: identify the packages that trigger these prompts and handle them via `--needed`, `pacman -S --ask 4`, or explicitly specifying the provider in `packages.x86_64`.

### Note: pacstrap Provider Prompts (Resolved)

The pacstrap provider prompt blocker (iptables/initramfs/jack) was resolved in a prior session. Installation now completes without prompting.
