# Aero Linux

**Version 0.3.0-pre — codename "First Boot"**
**Status: ALPHA — QEMU-verified. Physical hardware support is experimental.**

A custom Arch Linux distribution with a Hyprland Wayland desktop, Btrfs + Snapper snapshots, Limine bootloader, and an interactive TUI installer. Keyboard-first, Vim-motion philosophy. Builds as a bootable ArchISO.

> **Validation:** ISO builds, installs, boots, and reaches a Hyprland desktop **in QEMU** with zero failed systemd services and working Snapper root + home configs. **Real hardware boot currently fails before reaching the `liveuser` session — under investigation. Do not claim physical-hardware compatibility.**

## Quick start

```bash
git clone https://github.com/Blue16506/aero-linux.git
cd aero-linux
sudo bash build.sh                        # Build ISO -> out/*.iso (15-30 min)
bash test.sh live                         # Boot live ISO in QEMU (UEFI)
bash test.sh install --clean              # Fresh install (fresh qcow2 + OVMF)
bash test.sh boot                         # Boot installed system
```

Inside the live environment, run `aero-install` (or `sudo /usr/local/bin/aero-install`).

**Environments:**

| Environment | Status |
|---|---|
| QEMU UEFI live / install / first boot / desktop | ✅ Verified (Alpha-1 chain: direct `Hyprland`) |
| QEMU BIOS live | Boots (installer refuses BIOS mode — UEFI required) |
| VirtualBox (EFI, 3D acceleration ON) | ✅ Live desktop launches (user-verified). Two warnings pending: `.conf` deprecation (documented, Lua migration deferred) and `start-hyprland` launch warning (fixed in code, needs rebuild + retest) |
| VirtualBox (EFI, 3D acceleration OFF) | ❌ Hyprland/Aquamarine backend cannot initialize — 3D accel is a hard requirement (Hyprland wiki) |
| Physical hardware | ❌ Live ISO fails before `liveuser` session |

**Contents:** [1. Project Overview](#1-project-overview) · [2. Current State](#2-current-project-state) · [3. Repository Structure](#3-repository-structure) · [4. Architecture](#4-architecture) · [5. Installation](#5-installation-process) · [6. Btrfs](#6-btrfs-architecture) · [7. Snapper](#7-snapper-architecture--final-design) · [8. First Boot](#8-first-boot-system) · [9. Hyprland](#9-desktop--hyprland) · [10. Boot](#10-boot-process) · [11. Packages](#11-package-system) · [12. Config](#12-configuration-system) · [13. Versioning](#13-versioning-and-branding) · [14. Testing](#14-testing-and-verification) · [15. Known Issues](#15-known-issues-and-limitations) · [16. TODO](#16-todoroadmap) · [17. History](#17-development-history) · [18. Commands](#18-important-commands) · [19. Troubleshooting](#19-troubleshooting-guide) · [20. Critical Files](#20-files-that-are-critical-to-understand) · [21. Rules](#21-current-development-rules) · [22. Startup Guide](#22-future-opencode-session-startup-guide) · [23. Snapshot](#23-current-release-snapshot) · [24. AI Handoff](#24-ai-handoff-summary)

---

## 1. Project Overview

**What it is:** Aero Linux is a custom Arch Linux distribution (ArchISO-based) delivering a polished Hyprland Wayland desktop with Btrfs snapshot rollback via Snapper, a greetd + tuigreet login manager, Ghostty terminal, Waybar status bar, and an interactive Bash TUI installer (`aero-install`).

**Goals:**
1. Easy installation via interactive TUI installer
2. Modern Wayland desktop (Hyprland)
3. Reliable rollback (Btrfs + Snapper)
4. Fast boot (Limine)
5. Clean, modular configuration
6. Consistent visual design (Catppuccin-oriented, `aero-theme` manager)
7. Simple maintenance, reproducible ISO builds
8. Bash-first: pure Bash, no Python tooling

**Philosophy — Vim Motion Distribution (from README/TODO):** hands stay on the home row; keyboard-first, mouse optional; consistent motions across Hyprland, terminal, launcher, file manager, TUI tools; Super as primary modifier; composable Unix-style workflows. Implementation of the full philosophy (home-row scheme, unified bindings) is still on deck (Priority 4) — the current release establishes the working desktop foundation.

**Stack:**

| Component | Choice |
|---|---|
| Base | Arch Linux (rolling) |
| ISO builder | archiso (`mkarchiso`) |
| Bootloader (live ISO) | systemd-boot (UEFI) / syslinux (BIOS) |
| Bootloader (installed) | Limine (UEFI only in practice) |
| Filesystem | Btrfs (`@`, `@home`, `@cache`, `@log`) |
| Snapshots | Snapper (root + home, deferred to first boot) |
| Desktop | Hyprland (Wayland, uwsm session) |
| Login | greetd + tuigreet |
| Terminal | Ghostty |
| Bar / launcher / notifications / lock | Waybar / walker (AUR) / mako / hyprlock + hypridle |
| Shell | zsh (+ starship) |
| Network / audio | NetworkManager (+ iwd) / PipeWire + WirePlumber |
| Wallpaper | hyprpaper (migrated from swaybg; `swaybg` still packaged but unused) |

---

## 2. Current Project State

- **Version:** v0.3.0-pre · **Codename:** First Boot · **Milestone:** first end-to-end QEMU-verified pre-release (2026-06-17).

### Verified working (QEMU UEFI)

ISO builds; live boots to greetd/tuigreet; `liveuser` login; Hyprland + Waybar + Ghostty + Neovim + zsh/starship render with no deprecation warnings; mouse/keyboard work; NetworkManager DHCP + internet; yay builds/installs; PipeWire/WirePlumber active; TUI installer completes (partitioning, subvolumes, pacstrap, chroot, Limine to ESP, service enables); installed system boots via Limine to greetd → Hyprland; `aero-firstboot.service` runs once; Snapper root + home configs, valid `/.snapshots` + `/home/.snapshots` subvolumes, initial snapshots ("Initial Aero installation", "Initial Home snapshot"); `systemctl --failed` = 0.

### Not verified / broken

| Area | State |
|---|---|
| Physical hardware live boot | ❌ Fails before `liveuser` session (reproducible, root cause unknown) |
| Physical hardware install / first boot / desktop | ❌ Not verified |
| Audio output | ❌ Dummy Output (`auto_null`); `alsa-utils` absent, `aplay` missing |
| BIOS installed-system boot | 🔴 Broken — installer is UEFI-only |
| Snapshot boot entry | ⏳ Untested — `/Aero Linux (snapshots)` carries placeholder `X` |
| AUR/desktop first-boot installs | Unverified end-to-end in current flow |
| Waybar/Ghostty home deployment | Configs ship in `/usr/share/aero/configs/` but first-boot only deploys hyprpaper.conf + wallpaper symlink (see §12) |
| Login banner | Cosmetic — tuigreet shows `Linux` in some contexts (see §15) |

### Verification matrix

| Test | QEMU UEFI | QEMU BIOS live | Physical |
|---|---|---|---|
| ISO build | ✅ | ✅ | N/A |
| Live boot | ✅ | ✅ (live only) | ❌ fails pre-`liveuser` |
| Install | ✅ | Unverified | ❌ |
| First boot / Snapper / Hyprland / net | ✅ | Unverified | ❌ |

---

## 3. Repository Structure

```
aero/
├── README.md   # This file — canonical docs
├── build.sh                         # ISO build wrapper (mkarchiso)
├── test.sh                          # QEMU helper (live / install / boot)
├── profiledef.sh                    # archiso profile
├── pacman.conf                      # build-time pacman config
├── packages.x86_64                  # ISO package list (minimal, §11)
├── mkinitcpio.conf                  # build-time initramfs config (btrfs hooks)
├── airootfs/                        # ISO overlay
│   ├── etc/
│   │   ├── os-release               # Aero branding, 0.3.0-pre
│   │   ├── limine.conf              # installed-system bootloader template (X placeholder)
│   │   ├── mkinitcpio.conf
│   │   ├── greetd/config.toml       # -> /usr/local/bin/aero-greeter
│   │   ├── pam.d/greetd
│   │   ├── sudoers.d/aero-installer
│   │   ├── zsh/zshenv
│   │   ├── pacman.d/mirrorlist
│   │   ├── snapper/config-templates/{root,home}   # legacy templates (see §12)
│   │   └── systemd/system/
│   │       ├── aero-firstboot.service  # no After=/Wants=, conditions (§8)
│   │       └── snapper-boot.service    # snapper create boot snapshots (§7)
│   ├── root/
│   │   ├── customize_airootfs.sh    # archiso customization hook (liveuser, keyring, dotfiles)
│   │   ├── .automated_script.sh .zshrc .config/starship.toml
│   └── usr/
│       ├── local/bin/
│       │   ├── aero-install         # TUI installer (~579 lines)
│       │   ├── aero-greeter         # tuigreet wrapper (8 lines)
│       │   └── aero-theme           # theme manager (~183 lines)
│       └── share/aero/
│           ├── scripts/{first-boot.sh,hardware-detect.sh}
│           ├── packages/{aur.packages,desktop.packages}  # first-boot lists (§11)
│           ├── configs/{hypr,waybar,ghostty,mako,wlogout,walker,zsh,snapper/}
│           └── themes/catppuccin/
└── out/                             # ISO output (auto-discovered by test.sh)
```

Live-ISO boot dirs (`efiboot/`, `syslinux/`, `limine/` binaries) are standard archiso artifacts when present; `syslinux` also appears as an ISO package for live BIOS boot.

**Key file roles:** `build.sh` wraps `mkarchiso`; `test.sh` finds newest `out/*.iso` and drives QEMU/OVMF; `aero-install` owns partitioning → pacstrap → chroot → Limine → service enables → `/etc/aero-installed`; `first-boot.sh` owns Snapper init → AUR → XDG → hardware → branding → self-cleanup; `aero-firstboot.service` triggers it once; `snapper-boot.service` creates per-boot snapshots thereafter.

---

## 4. Architecture

```mermaid
flowchart TD
    subgraph BUILD["ISO build"]
        B[build.sh] --> P[profiledef.sh + packages.x86_64]
        P --> M[mkarchiso]
        M --> ISO[out/*.iso]
    end
    subgraph LIVE["Live env"]
        ISO --> SB[systemd-boot / syslinux]
        SB --> K[Kernel + initramfs]
        K --> G[greetd/tuigreet -> liveuser]
        G --> H[Hyprland via start-hyprland]
        H --> I[aero-install]
    end
    subgraph INSTALL["Install"]
        I --> PART[GPT ESP + Btrfs]
        PART --> SUBV["@, @home, @cache, @log"]
        SUBV --> PAC[pacstrap]
        PAC --> CHR[arch-chroot config]
        CHR --> LIM[Limine to ESP]
        LIM --> MK[/etc/aero-installed + enable services]
        MK --> RB[Reboot]
    end
    subgraph FB["First boot"]
        RB --> SV[aero-firstboot.service]
        SV --> SH[first-boot.sh P1..P7]
        SH --> SNP[Snapper create-config + templates + initial snapshots]
        SNP --> REST[net-wait, AUR, XDG, hw-detect, branding, cleanup]
    end
    subgraph NORM["Normal boot"]
        RB --> N[systemd]
        N --> SSB[snapper-boot.service]
        SSB --> G2[greetd -> Hyprland]
    end
```

**Package flow:** `packages.x86_64` → mkarchiso → live squashfs → `aero-install` pacstraps base + same desktop set into `@`. `desktop.packages` (repo) + `aur.packages` (AUR) install only at first boot, not into the ISO.

**Config flow:** `airootfs/etc/` → `/etc`; `airootfs/usr/{local/bin,share/aero}` → system paths; installer chroot writes hostname/locale/users/mkinitcpio/greetd/Limine; first-boot writes Snapper configs + hyprpaper.conf + wallpaper symlink into user home.

**Btrfs layout (summary, full detail §6):** `@`→`/`, `@home`→`/home`, `@cache`→`/var/cache`, `@log`→`/var/log`. No `@snapshots` from installer; Snapper creates nested `/.snapshots`, `/home/.snapshots` on first boot.

---

## 5. Installation Process

`aero-install` (~579 lines, pure Bash, `set -euo pipefail`, TUI via `/dev/tty`, return values via stdout, logs to `/var/log/aero-install.log` with `exec 2>"$INSTALL_LOG"` after the root check at ~line 174):

0. **Preflight** — Aero banner, root EUID check, `INSTALL_LOG` set (line 9; prior unbound-variable regression fixed).
1. **Localization** — timezone TUI with search (`timedatectl list-timezones`), locale (en_US.UTF-8 default), keymap (auto-detect fixed via command substitution; interactive fallback).
2. **Network** — interface list, NetworkManager attempt.
3. **User** — username validation, hidden password + confirm; root password handling noted in audit as silently mirroring user password — treated as known security/cosmetic debt, not verified fixed.
4. **Disk** — block device menu (`/dev/tty` rendering; fixes invisible-menu bug), destructive-confirm; **UEFI only** (installer aborts on BIOS boot before touching disks).
5. **Partitioning** — GPT: 512M FAT32 ESP + remainder Btrfs (`parted`; `parted` added to ISO pkgs after missing-dependency bug).
6. **Subvolumes** — `mkfs.btrfs -L AERO`, create `@ @home @cache @log`, mount with `ssd,space_cache=v2`; ESP mounted at `/boot` (FAT32) so Limine reads kernel/initramfs directly.
7. **Pacstrap** — base + `packages.x86_64` set; provider-prompt blocker (iptables/initramfs/jack) recorded as resolved in prior session; yay built via `makepkg -d` + root `pacman -U` (avoids interactive sudo prompt).
8. **Chroot** — localtime, locale-gen, hostname, users/wheel/sudoers, NetworkManager enable, mkinitcpio `-P`, greetd/tuigreet (`--cmd start-hyprland`) config, desktop config seeding. **No `snapper create-config` here.**
9. **Handoff** — copy Snapper templates to `/usr/share/aero/configs/snapper/`; enable `aero-firstboot`, `snapper-boot`, `snapper-cleanup.timer`, `snapper-timeline.timer`; write `/etc/aero-installed` (+ `/etc/aero-install.conf` for first-boot); Limine `BOOTX64.EFI` to ESP fallback path + `limine.conf` from template with real UUID.
10. **Done** — unmount, summary, reboot prompt.

---

## 6. Btrfs Architecture

Installer creates exactly:

```bash
btrfs subvolume create /mnt/@        # /
btrfs subvolume create /mnt/@home    # /home
btrfs subvolume create /mnt/@cache   # /var/cache (excluded from snapshots)
btrfs subvolume create /mnt/@log     # /var/log   (excluded from snapshots)
```

No `@snapshots`. Installed fstab (UUID-based):

```
UUID=… /                  btrfs  rw,relatime,ssd,space_cache=v2,subvolid=… 0 0
UUID=… /.snapshots        btrfs  … 0 0   # after first boot
UUID=… /home              btrfs  … 0 0
UUID=… /home/.snapshots   btrfs  … 0 0   # after first boot
UUID=… /var/cache         btrfs  … 0 0
UUID=… /var/log           btrfs  … 0 0
UUID=… /boot              vfat   … 0 0
```

First boot runs `snapper -c root create-config /` and `snapper -c home create-config /home`, creating nested `/.snapshots` and `/home/.snapshots`. Snapper templates then set `ALLOW_GROUPS=wheel`, number/timeline/empty-pre-post cleanup limits (root/home under `/usr/share/aero/configs/snapper/`).

---

## 7. Snapper Architecture — Final Design

**Why deferred:** `snapper create-config` fails in `arch-chroot` (`IO Error (subvolume is not a btrfs subvolume)`) — chroot lacks live Btrfs kernel/udev support. Debugging path: suspected `@snapshots` collision → proved failure persists without it → root-caused to chroot → moved init to booted system. (Merged from README/PROJECT_CONTEXT/TESTING/TODO, which all carry this section.)

**Final split:**

```
Install (chroot): install snapper pkg, copy templates, enable units. NO create-config.
First boot: create-config / + /home, overlay templates, initial snapshots.
```

`first-boot.sh` `init_snapper()` (Phase 1, local, pre-network): checks `snapper list-configs` for `root`/`home`, creates missing configs, verifies, guarded-copies templates only if `/etc/snapper/configs/{root,home}` exist, creates initial snapshots idempotently by description match ("Initial Aero installation", "Initial Home snapshot"). Safe to re-run.

**`snapper-boot.service` (actual, corrected):** calls Snapper, not raw btrfs:

```ini
ConditionPathExists=/.snapshots
ExecStart=/usr/bin/snapper -c root create --description "boot" --cleanup number
ExecStart=-/usr/bin/snapper -c home create --description "boot" --cleanup number
```

The `-` prefix on home tolerates missing home config. Guard ensures it only runs after first-boot created `/.snapshots`. Install section `WantedBy=multi-user.target` present (older audit claiming "no Install, dead" is superseded).

**Verified (QEMU):** `list-configs` shows root+home; subvolumes valid; initial + boot snapshots appear; `systemctl --failed` = 0.

---

## 8. First-Boot System

**`aero-firstboot.service` (actual):** oneshot, `RemainAfterExit=yes`, logger `ExecStartPre/Post`, `StandardOutput/Error=journal+console`, `WantedBy=multi-user.target`, **no `After=`/`Wants=`** (script does its own network wait; earlier `After=graphical.target` caused a soft ordering cycle and was removed). Guards: `ConditionPathExists=/etc/aero-installed` and `!/etc/aero-firstboot-complete` — runs exactly once.

**`first-boot.sh` phases:** P0 preflight (root, marker, `/etc/aero-install.conf`); P1 Snapper (§7); P2 network wait (~60s `ping archlinux.org`); P3 AUR via `yay` from `aur.packages`; P4 `xdg-user-dirs-update`; P5 `hardware-detect.sh`; P6 branding (wallpaper symlink + hyprpaper.conf deploy + `aero-theme apply catppuccin` best-effort); P7 cleanup (disable unit, remove unit link, `touch /etc/aero-firstboot-complete`, `exit 0`). ERR trap logs `FAILED at line $LINENO`; full log to `/var/log/aero-firstboot.log`; `|| true` / `2>/dev/null` on non-critical ops. No self-`systemctl stop` (prior SIGTERM loop removed).

**Post-state:** completion marker exists; Snapper configs + snapshots present; AUR best-effort; service inert thereafter.

---

## 9. Desktop / Hyprland

`greetd (greeter user) → /usr/local/bin/aero-greeter (tuigreet wrapper) → --cmd start-hyprland → start-hyprland (Hyprland package watchdog binary) → Hyprland`. `autostart.conf` uses `uwsm-app -- hypridle/waybar/hyprpaper` + polkit-gnome agent + `systemctl --user import-environment` + `dbus-update-activation-environment` + `hyprctl setcursor`. (History: commit f48e267 switched the greeter to `start-hyprland`; during VirtualBox debugging it was reverted to direct `Hyprland`, which was misdiagnosed as the fix. Root cause was the graphics layer — VirtualBox 3D acceleration disabled. With 3D enabled the live desktop launches; the greeter was restored to `start-hyprland` — the package-recommended launcher (Arch ships `hyprland.desktop` with `Exec=/usr/bin/start-hyprland`), identical to the installer's installed-system greetd command. **Restored-but-not-yet-retested.**)

Modular `~/.config/hypr/`: `hyprland.conf` sources `monitors/input/binds/appearance/autostart/windowrules` (+ deployed `hyprpaper.conf`). Live ISO keybindings include Vim-style fixes (`j/k` + arrows in selectors, `windowrule` modern syntax after Hyprland 0.55 migration, `debug.vfr` relocation, pseudotile/Ghostty-GPU options removed upstream).

**Wallpaper:** hyprpaper primary (`exec-once`), default `/usr/share/backgrounds/aero/default.jpg` (Catppuccin gradient 4K). `swaybg` remains packaged but unused — intentional transitional leftover, not active path. Desktop intentionally black until first-boot branding applies theme.

**Waybar:** `config.jsonc` + `style.css` ship under `/usr/share/aero/configs/waybar/`; modules left/center/right = workspaces / window / tray+pulseaudio+network+bluetooth+cpu+memory+clock+power (`wlogout`); network click → `nm-connection-editor`, power → `wlogout`, pulse scroll adjusts volume. **Persistence gap:** first-boot does not copy Waybar config into user home — live/installed session uses shipped defaults.

**Ghostty:** installed as default terminal (`Super+Enter`), config ships at `.../configs/ghostty/config`, but like Waybar it is not explicitly deployed to home by first-boot — works from defaults; launcher keybinding present while `walker` itself arrives only via AUR first-boot.

---

## 10. Boot Process

Live: UEFI systemd-boot / BIOS syslinux → kernel+initramfs → live root → greetd/tuigreet (`liveuser`, no password) → Hyprland. Installed (UEFI): Limine (`/Aero Linux`, fallback, terminal `multi-user.target`, snapshots, UEFI Shell) → `root=UUID=… rootflags=subvol=@ quiet…` → systemd → greetd → Hyprland; first boot additionally runs `aero-firstboot.service` under `multi-user.target`.

`limine.conf` template uses `boot():/vmlinuz-linux` style paths (Limine v12 `/Title` syntax; `reboot`/`poweroff` protocols removed as unsupported). Kernel/initramfs live on FAT32 ESP at `/boot`.

**Limits:** installed BIOS boot unsupported (installer guards: refuses BIOS mode pre-destruction); snapshot entry untested (`subvol=@/.snapshots/X/snapshot` — `X` must become a real snapshot number; no selector tooling yet); physical-hardware boot fails pre-`liveuser` (indistinguishable so far whether ISO boot, KMS, or greetd stage).

---

## 11. Package System

Three distinct lists — do not conflate:

**`packages.x86_64` (ISO, minimal — actual):** `base linux linux-firmware base-devel btrfs-progs snapper archiso mkinitcpio-archiso limine syslinux parted hyprland hyprlock hypridle hyprpaper waybar uwsm greetd greetd-tuigreet ghostty zsh{,-autosuggestions,-syntax-highlighting,-completions} tmux git vim neovim nano networkmanager iwd pipewire wireplumber pipewire-pulse xdg-desktop-portal-{hyprland,gtk} polkit-gnome gnome-keyring brightnessctl playerctl pamixer grim slurp wl-clipboard swaybg fzf ripgrep fd bat eza zoxide sudo reflector pacman-contrib noto-fonts{,-emoji} ttf-jetbrains-mono-nerd starship btop lazygit virtualbox-guest-utils`. Notably **absent:** `firefox`, `libreoffice`, `mpv`, `alsa-utils`, `pipewire-alsa/jack`, `walker`, `archinstall` (audit suggestion to drop `archinstall` already reflected — not present).

**`desktop.packages` (first-boot via pacman):** `firefox libreoffice-fresh mpv imv noto-fonts-cjk ttf-ia-writer btop lazygit`.

**`aur.packages` (first-boot via yay, `#` ignored):** active `visual-studio-code-bin spotify walker-bin`; browsers/chat entries commented (use extra repos instead).

**Audio inventory (actual):** `pipewire wireplumber pipewire-pulse pamixer playerctl` present; `alsa-utils`, `pipewire-alsa`, `pipewire-jack/jack2` absent → `auto_null` Dummy Output, `aplay` missing. RTKit/BlueZ/libcamera warnings in QEMU are expected non-fatal.

**Duplication (confirmed):** `btop`, `lazygit` in both ISO list and `desktop.packages` — cosmetic, causes redundant reinstall at first boot.

**VirtualBox guest integration (staged, untested):** `virtualbox-guest-utils` ships in the ISO (resolves cleanly from `extra`; kernel modules `vboxguest`/`vboxsf` ship in the `linux` package itself, confirmed via `modinfo`). On first boot, `hardware-detect.sh` (`oracle` virt type) ensures the utils are installed, enables `vboxservice.service` (automount + clipboard daemon), and adds human users (UID 1000–59999) to the `vboxsf` group. Shared folders additionally require: the folder configured with Automount in VirtualBox settings, and a re-login for group membership to take effect. No VirtualBox testing has been performed — do not claim it works.

---

## 12. Configuration System

| Source | Ships to | Applied |
|---|---|---|
| `airootfs/etc/` | `/etc/` | ISO build / pacstrap |
| `airootfs/usr/local/bin/` | `/usr/local/bin/` | ISO / installed |
| `airootfs/usr/share/aero/` | `/usr/share/aero/` | ISO / installed |
| `airootfs/etc/snapper/config-templates/` | legacy templates | Superseded by `/usr/share/aero/configs/snapper/` active templates |
| `first-boot.sh` | user home + `/etc/snapper` | First boot only |

First-boot home deployment is narrow: wallpaper symlink `~/.config/aero/wallpaper` + `~/.config/hypr/hyprpaper.conf` + `aero-theme apply catppuccin` (best-effort `hyprctl hyprpaper preload/wallpaper`, `swaybg` fallback, `hyprctl reload`, waybar/mako reloads). Remaining Hyprland fragments, Waybar, Ghostty, mako, wlogout, walker, zsh arrive via installer/ISO seeding, not per-file first-boot copies. `aero-theme` (`list/apply/current/help`) overlays per-theme `hyprland.conf/waybar.css/ghostty.conf/mako.conf/walker.css/starship.toml/wallpaper.jpg` into `~/.config/`; only `catppuccin` ships.

Runtime files: `/etc/aero-installed`, `/etc/aero-install.conf`, `/etc/aero-firstboot-complete`, `/var/log/aero-{install,firstboot,hardware}.log`.

---

## 13. Versioning and Branding

`airootfs/etc/os-release` (actual): `NAME="Aero Linux"`, `ID=aero`, `PRETTY_NAME="Aero Linux 0.3.0-pre (First Boot)"`, `VERSION_ID=0.3.0-pre`, `VERSION_CODENAME="First Boot"`, GitHub URLs, `LOGO=aero`, `ANSI_COLOR=1;36`. Convention: `Major.Minor.Patch` + `-pre` pre-1.0. History in-repo: early `v0.1.x-alpha` → `0.3.0-pre`. Branding: ASCII banner in installer/greeter, Catppuccin gradient wallpaper, cyan ANSI. License: **to be determined** (no LICENSE/COPYING file in repo).

---

## 14. Testing and Verification

`test.sh` auto-discovers newest `out/*.iso`; modes `live live-bios install [install --clean] boot cleanup`. QEMU: `-enable-kvm -m 4G -smp 2 -cpu host`, virtio disk (20G qcow2 `/tmp/aero-test-disk.qcow2`), user NAT, GTK display, OVMF 4m (`/tmp/OVMF_VARS.4m.fd` persistent — stale vars cause PXE fallthrough; `--clean` deletes). Requires `qemu-desktop edk2-ovmf`; build requires Arch host + `archiso limine`.

Use `--clean` for partitioning/bootloader/filesystem changes; reuse qcow2 for desktop-only iteration. Install prompts: timezone TUI (`/dev/tty`, arrows+Enter), keymap detect, disk confirm, hostname/username/password; pacstrap ~3 GiB, 5–15 min; cosmetic `libcrc32c` mkinitcpio warning noted.

Verify inside installed system:

```bash
systemctl --failed                                  # expect 0
snapper list-configs                                 # root + home
sudo btrfs subvolume show /.snapshots               # valid
ls /etc/snapper/configs                              # root home
systemctl status snapper-boot snapper-cleanup.timer snapper-timeline.timer
snapper -c root list                                 # initial snapshots
journalctl -u aero-firstboot.service -b
ls /etc/aero-firstboot-complete
```

Live-vs-installed: live uses systemd-boot + `liveuser`, no AUR/desktop/Snapper; installed uses Limine + created user + first-boot AUR/desktop + Snapper.

---

## 15. Known Issues and Limitations

**Blockers:** physical-hardware live boot fails pre-`liveuser` (unknown cause; kills bare-metal validation); installed BIOS boot unsupported — the installer now aborts with an actionable error on BIOS boot **before any destructive disk operation** (UEFI-only; broken `limine-install /dev/DISK` branch unreachable).

**Implemented this session (2026-10-17) — ISO rebuild + VirtualBox retest required, do not claim fixed until then:**
- **Hyprland exit in VirtualBox:** the greeter launch-path change in commit f48e267 (`--cmd Hyprland` → `--cmd start-hyprland`) was initially misdiagnosed as the root cause (the messages `Couldn't waitpid for hyprland` / `Hyprland exited cleanly` come from the Hyprland-package watchdog binary). The direct-launch revert did **not** fix it — the next test failed identically. **Actual root cause: VirtualBox 3D acceleration disabled.** Hyprland's Aquamarine DRM/GBM-EGL backend cannot initialize without it (official Hyprland wiki: VMs require 3D acceleration or it will not work). With 3D acceleration enabled, the VirtualBox live Hyprland desktop launches successfully (user-verified). `aero-greeter` has been restored to `--cmd start-hyprland` (the package-recommended launcher — Arch's own `hyprland.desktop` uses `Exec=/usr/bin/start-hyprland`; matches the installer's installed-system greetd command). Restored-but-not-retested.
- **`.conf` format deprecation warning (config, not launch):** Hyprland 0.56 prints "You are using the .conf config format, support for which will be removed in Hyprland 0.57". Source evidence: all Aero configs are hyprlang `.conf` files (`airootfs/usr/share/aero/configs/hypr/*`), deployed to `~/.config/hypr/hyprland.conf` (live via `customize_airootfs.sh`, installed via installer/first-boot). Verified: the configs contain **no** legacy `windowrulev2` directives (modernized in f48e267) — the warning is triggered by the `.conf` format itself, not by a compatibility path or directive. The replacement format is a **Lua config API** (`hyprland.lua`, `hl.config{}`/`hl.bind(...)`/`hl.dsp.*`, `require()`-based splitting). Conversion is a full rewrite of 7 files and **cannot be statically verified** (the `hl` API needs a running compositor), so it is deferred — the warning is cosmetic in 0.56.x. **P0 risk: Arch is rolling — once 0.57 lands in `extra`, the next rebuild breaks the live desktop and installed sessions; the Lua migration must be completed before the next Hyprland major bump.**
- **`Initial Setup` timezone wizard on live boot:** the "Please enter the new timezone name or number" screen is `systemd-firstboot` (ConditionFirstBoot), not `aero-firstboot.service` (which contains no timezone code). `customize_airootfs.sh` never wrote `/etc/locale.conf`/`/etc/localtime`, so the wizard ran interactively on `/dev/console`. Fixed: live env now presets `LANG=en_US.UTF-8`, `localtime → UTC`, and masks `systemd-firstboot.service`. Timezone selection remains untouched in `aero-install` (Phase 1 TUI → `/etc/localtime` for the installed system); installed-system first-boot is unchanged.
- **Console overlap/artifacts:** `systemd-firstboot` console output racing greetd was the overlap source; additionally kernel console spam (kmsg on the VT) is now silenced via `quiet loglevel=3` on the UEFI (`efiboot/loader/entries/01-aero-linux.conf`) and BIOS (`syslinux/archiso_sys-linux.cfg`, both entries) kernel cmdlines, plus `airootfs/etc/sysctl.d/20-quiet-console.conf` (`kernel.printk = 3 3 3 3`). `journalctl -k` still retains full logs when failures occur.

**High:** audio Dummy Output (`alsa-utils` missing; §11); login banner shows `Linux` in some tuigreet contexts despite correct `os-release` (cosmetic; needs greeter `issue` string check, not just os-release).

**Medium:** snapshot boot `X` placeholder untested, no rollback verification; installer no rollback path, limited error handling; NVIDIA hook filename is correct (`nvidia.hook`) but hook mixes `Target=usr/lib/modules/*/vmlinuz` under `Type=Package` — path targets normally want `Type=Path`, so hook may misfire (unverified on NVIDIA hardware); `btop`/`lazygit` duplicated; root-password-mirrors-user-password debt from audit (unverified fixed).

**Low/unknown:** Waybar/Ghostty home persistence gap; AUR first-boot unverified; walker keybinding dead until AUR installs; ISO ~1.8 GB (`linux-firmware` ~700 MB + `base-devel` ~200–300 MB) vs 800 MB target; `swaybg` packaged-but-unused; **host-side keyboard capture in VirtualBox**: `Super+Enter` fired on the host instead of the guest — audited guest config as correct (`binds.conf:7` `bindd = $mainMod, RETURN, Terminal, exec, ghostty`; no duplicate/conflicting binds; `ghostty` on ISO line 30) — VirtualBox keyboard-capture/host-WM issue, no repo change made.

**Corrected stale claims (do not reintroduce):** no `.hhook` typo exists; no `pass`/`fi` syntax bug in `aero-theme`; `snapper-boot` has `[Install]` and is enabled (2026-06-14 audit statement superseded); `INSTALL_LOG` regression fixed.

---

## 16. TODO/Roadmap

**P0 — Critical:** investigate bare-metal boot failure (capture Limine? kernel? greetd? stage); add `alsa-utils` (+ evaluate `pipewire-alsa`) and QEMU audio test (`speaker-test/pw-play`); decide BIOS: implement Limine-BIOS installed path or officially drop + remove `syslinux` ambiguity; **Hyprland `.conf` → Lua (`hl.*` API) config migration before Hyprland 0.57 removal hits Arch `extra` (rolling — breaks live + installed desktops on next major bump; cannot be statically validated, plan VirtualBox+QEMU retest with the new files)**.

**P1:** snapshot-boot design (resolve `X` → real snapshot selection/tooling, then test); dedupe `btop/lazygit`; fix NVIDIA hook `Type` mix; verify AUR + desktop first-boot lists end-to-end.

**P2:** Waybar/Ghostty home deployment; installer error handling/rollback; separate root password prompt; Bluetooth/firewall defaults.

**P3/Future:** Vim-motion scheme (Super+hjkl, unified launcher/terminal/FM/TUI bindings, design doc); kernel selection; LUKS; ISO diet (`linux-firmware` trim, drop `base-devel` from ISO if installer pacstraps it); release pipeline/signing; screenshots.

Completed 2026-06-13→17 (preserved from TODO): archiso profile, packages, build/test scripts, mkinitcpio/Limine/greetd/PAM/sudoers/mirrorlist/zshenv/os-release, both systemd units, installer/first-boot/hw-detect/greeter/theme, live customization (keyring, dotfiles via `cp …/.`, `aero-install` alias, `parted` dep), desktop configs (Hyprland×7, Waybar, Ghostty, zsh×6, mako, wlogout, walker+Catppuccin, Snapper templates, wallpaper), TUI/`/dev/tty` fixes, `makepkg -d`+`pacman -U` yay fix, Hyprland 0.55 migrations, uwsm greeter switch, ESP-at-`/boot` + Limine-v12 `/Title` + `boot():/` fix, Snapper deferral + ordering + diagnostics + QEMU verification.

---

## 17. Development History

- **Boot architecture (06-13):** ESP moved `/efi`→`/boot`; dropped `limine-install`-in-chroot reliance → copy `BOOTX64.EFI` to fallback path; fixed `boot():/` kernel paths; Limine v12 `/Title` (not `entry "Title"`); removed `reboot`/`poweroff` protocols; stale OVMF_VARS root-caused PXE fallthrough.
- **TUI reliability:** `/dev/tty` rendering; `select_opt` Enter/newline + `echo`-return fix; `KEYMAP=$(…)` subshell fix; log redirection after root check; `parted` dep; pacman keyring (`pacman-init`) parity with releng; yay no-prompt build split.
- **Desktop modernization:** swaybg→hyprpaper; `windowrulev2`→`windowrule` (14 rules); `pseudotile`/`misc.vfr`/`gpu-accelerated` removals; `Hyprland`→`start-hyprland`/uwsm; walker moved ISO→AUR (`walker-bin`).
- **Snapper saga (06-17):** chroot failure root-caused → deferred to first boot → ordering cycle (`After=graphical.target` × `WantedBy=multi-user.target`) removed → self-stop SIGTERM removed → ERR trap/phase logging/`|| true`/`exit 0` → `INSTALL_LOG` fix → QEMU-verified zero-failed.
- **Versioning:** `v0.1.x-alpha` first desktop → `0.3.0-pre "First Boot"` QEMU-verified pre-release; `-pre` convention established.
- **Audit note:** `PROJECT_AUDIT.md` (06-14) metrics (~67 files, ~4.4k LOC, 10 scripts, 26 configs, 2 units, 3 pkg lists, ~1.8 GB ISO) and size/security findings preserved here in substance; its "snapper-boot dead / KEYMAP dead / yay masked" items are superseded by later fixes above.

Problem→cause→fix→state pattern holds for each: TUI invisible menu→`>&2`-in-subshell→`/dev/tty`→renders; yay password prompt→`makepkg -si` internal sudo→`makepkg -d`+root `pacman -U`→non-interactive; missing `.zshrc`→`cp *` skips dotfiles→`cp .`→wizard gone; blank wallpaper→swaybg-era→hyprpaper+first-boot theme→verified.

---

## 18. Important Commands

```bash
sudo bash build.sh                  # build ISO
bash test.sh live | live-bios       # live QEMU
bash test.sh install [--clean]      # install (clean = fresh qcow2+OVMF)
bash test.sh boot                   # boot installed
bash test.sh cleanup                # remove test disk
bash -n <script>                    # syntax check (no shellcheck dependency assumed)
systemctl --failed; snapper list-configs; snapper -c root list; snapper -c home list
btrfs subvolume list /; btrfs subvolume show /.snapshots
systemctl status aero-firstboot snapper-boot; systemctl list-timers 'snapper-*'
cat /var/log/aero-install.log /var/log/aero-firstboot.log
journalctl -u aero-firstboot.service -b
ls /etc/aero-installed /etc/aero-firstboot-complete
pacman -Q {snapper,hyprland,pipewire,alsa-utils}; pacman -Ql hyprland | head
```

---

## 19. Troubleshooting Guide

- **Installer fails:** check root (`id`), disk busy (`mount|grep sd`), space (`df -h`), net (`ping archlinux.org`), then `/var/log/aero-install.log`. No rollback — wipe and `install --clean`.
- **First-boot absent:** check `/etc/aero-installed` present, `/etc/aero-firstboot-complete` absent, `systemctl status aero-firstboot`, `journalctl -u aero-firstboot.service -b`.
- **Snapper empty:** `pacman -Q snapper`; `grep -i snapper /var/log/aero-firstboot.log`; `btrfs subvolume list /|grep snapshots`; retry `snapper -c root create-config /` manually (booted system only, never chroot).
- **Hyprland black/loop:** check `XDG_RUNTIME_DIR`, `journalctl --user -xe|grep -i hypr`, `~/.config/hypr/hyprland.conf` sources, waybar/hyprpaper `exec-once`, TTY test.
- **Wallpaper black:** expected until first-boot branding; check `~/.config/aero/wallpaper`, `~/.config/hypr/hyprpaper.conf`, `hyprctl hyprpaper list`.
- **Bootloader missing:** from live ISO inspect `/mnt/boot/EFI/BOOT/{BOOTX64.EFI,limine.conf}`; fallback path needs no NVRAM.
- **QEMU PXE/stale disk:** `rm -f /tmp/OVMF_VARS.4m.fd /tmp/aero-test-disk.qcow2` or `install --clean`; TUI needs graphical display, not `-nographic`.
- **Physical HW:** no shell available (fails pre-`liveuser`); record firmware/SecureBoot/GPU/USB details; use QEMU for dev.

---

## 20. Files That Are Critical to Understand

| File | Why |
|---|---|
| `airootfs/usr/local/bin/aero-install` | Entire install pipeline |
| `airootfs/usr/share/aero/scripts/first-boot.sh` | Post-install orchestration + Snapper |
| `airootfs/etc/systemd/system/aero-firstboot.service` | Once-only trigger, ordering gotchas |
| `airootfs/etc/systemd/system/snapper-boot.service` | Per-boot snapshots, `/.snapshots` guard |
| `airootfs/usr/share/aero/configs/snapper/{root,home}` | Active Snapper templates |
| `airootfs/etc/limine.conf` | Boot entries incl. `X` placeholder |
| `airootfs/etc/greetd/config.toml` + `usr/local/bin/aero-greeter` | Login → Hyprland path |
| `airootfs/usr/share/aero/configs/hypr/{hyprland,autostart}.conf` | Session composition |
| `packages.x86_64` + `.../packages/{desktop,aur}.packages` | Three-list package model |
| `profiledef.sh pacman.conf mkinitcpio.conf` | ISO build identity |
| `build.sh test.sh` | Build/test workflow |
| `airootfs/root/customize_airootfs.sh` | Live user/keyring/dotfiles |

---

## 21. Current Development Rules

- QEMU-first: verify in QEMU before claiming; never equate QEMU with hardware.
- Minimal diffs; preserve Bash idioms (`set -euo pipefail`, `info/warn/error/ok`, `/dev/tty` for TUI, stdout for values, stderr/logs for diagnostics).
- Service rules: never `snapper create-config` in chroot; never re-add `After=graphical.target` to first-boot; never self-stop oneshot (`RemainAfterExit=yes` + `exit 0`).
- Versioning: `Major.Minor.Patch` + `-pre`; update `os-release` fields together; changelog entry per release (now §23/history here).
- Docs: record limits prominently; separate verified vs expected; check code when docs conflict.

---

## 22. Future OpenCode Session Startup Guide

1. Read this file first.
2. `git log --oneline -10; git status; git diff` — confirm clean except intended docs.
3. Map task → §15/§16 item; read the listed critical files before editing.
4. Smallest change; no refactors/renames; no source/config edits for doc tasks.
5. `bash -n` changed scripts; rebuild + QEMU only when explicitly tasked (never claim hardware).
6. Update this file when architecture/state changes; keep version `0.3.0-pre` unless code says otherwise.

---

## 23. Current Release Snapshot

| Field | Value |
|---|---|
| Version / codename / milestone | v0.3.0-pre / First Boot / first QEMU-verified pre-release |
| Base / desktop / fs / snapshots | Arch rolling / Hyprland+uwsm / Btrfs 4-subvol / Snapper deferred |
| Installer / first boot / testing | `aero-install` TUI / `aero-firstboot` P1–P7 / `test.sh` QEMU |
| QEMU | ✅ verified end-to-end |
| Hardware / BIOS / audio / snapshot-boot | ❌ fails pre-`liveuser` / 🛡 guarded (installer requires UEFI) / ❌ Dummy Output / ⏳ `X` untested |
| VirtualBox | ⚠️ 3D ON: live desktop launches ✅; greeter restored to `start-hyprland` (untested); `.conf` deprecation pending Lua migration (P0 before Hyprland 0.57) |
| Next | rebuild ISO → VirtualBox retest (start-hyprland restore + guest-utils §11), alsa-utils, bare-metal triage, Lua config migration |

**v0.3.0-pre changelog (2026-06-17, merged from CHANGELOG.md):** deferred Snapper init; idempotent root/home setup + initial snapshots; ordering-cycle fix; self-termination removal; zero failed services; QEMU-verified pipeline. Changed: first-boot service (ordering→none + logger), `first-boot.sh` (trap/phases/guards/`exit 0`, Snapper→P1), installer (`INSTALL_LOG` fix, Snapper-out-of-chroot), `packages.x86_64` (`snapper` present). Limits: hardware, audio, banner, snapshot entry, BIOS, NVIDIA hook.
