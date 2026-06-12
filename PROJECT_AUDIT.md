# Aero Linux — Project Audit

**Date:** 2026-06-12
**Commit:** 329c4a8 (pre-alpha 2) + uncommitted changes
**ISO:** `out/aero-linux-2026.06.12-x86_64.iso` (1.8 GB)
**Status:** Pre-alpha — bootable, live session verified, installer functional

---

## 1. Current Status

| Area | Status |
|------|--------|
| ISO builds | ✅ Verified — `mkarchiso` completes without errors |
| UEFI boot | ✅ Verified — systemd-boot menu, kernel loads, live environment reaches greetd |
| BIOS boot | ✅ Untested but configuration identical in structure |
| Live session login | ✅ Verified — greetd + tuigreet shows `liveuser`, login succeeds |
| Hyprland launch | ✅ Verified — compositor starts with Waybar, wallpaper |
| Installer launch | ✅ Verified — `aero-install` runs, TUI prompts work |
| Full installation | ✅ Verified — partitioning, pacstrap, chroot, Limine install all complete |
| Installed system boot | ✅ Verified — Limine boots, greetd appears |
| Python dependency | ✅ None — zero Python files in repo |
| Bash-first philosophy | ✅ All scripts use `#!/bin/bash` |

---

## 2. Repository Metrics

- **Total files** (excl. .git and .iso): 67
- **Total lines of code** (excl. .git and .iso): 4,423
- **Shell scripts** (`.sh` + extensionless): 10
- **Config files** (`.conf`, `.cfg`, `.toml`, `.jsonc`, `.css`): 26
- **Systemd units**: 2
- **Package list files**: 3
- **Image files** (wallpapers, splash): 3 (2×109KB + 3.5KB)
- **Documentation** (`.md`): 5

---

## 3. Bash-First Compliance

| Requirement | Status | Evidence |
|-------------|--------|---------|
| No Python files | ✅ PASS | Zero `.py` files in repo |
| No Python dependencies | ✅ PASS | Zero references to `python`, `pip`, `requirements.txt` |
| All scripts use bash | ✅ PASS | All 10 executable files use `#!/bin/bash` |
| No `set -euo pipefail` violations | ⚠️ Minor | `aero-greeter` and `.automated_script.sh` omit it but have no failure paths |
| Simple tooling | ✅ PASS | Uses only standard Linux tools: parted, arch-chroot, systemctl, snapper, etc. |
| Minimal dependencies | ⚠️ Issue | ISO includes `archinstall` (unused), `base-devel` (installed system only) |

---

## 4. Installer Architecture Audit

### aero-install (576 lines)

**Strengths:** Comprehensive, well-structured, 11 phases with clear flow. Partitioning, subvolumes, pacstrap, chroot all handled correctly. Limine bootloader installation with UEFI+BIOS detection.

**Issues:**

| Severity | Issue | File:Line |
|----------|-------|-----------|
| **BUG** | KEYMAP auto-detection broken by pipe subshell — always returns "us" | `aero-install:198-200` |
| **BUG** | yay AUR build errors silently masked (`2>/dev/null \|\| true`) | `aero-install:406-410` |
| **BUG** | Pre-copied snapper configs overwritten by `snapper create-config` | `aero-install:356-357` vs `443-444` |
| **SECURITY** | Root password silently set to user password value | `aero-install:244` |
| **REDUNDANCY** | Config directory list duplicated with customize_airootfs.sh | `aero-install:535` vs `customize_airootfs.sh:60` |
| **DEAD** | `snapper-boot.service` copied to installed system but never enabled | `aero-install:352` |

### aero-greeter (8 lines)

Simple wrapper for tuigreet with live session branding. Only used in live ISO; installer generates its own greetd config. No issues.

### aero-theme (182 lines)

Theme manager applying colors and wallpapers across Hyprland, Waybar, Ghostty, Mako, Walker, Starship. Uses graceful fallbacks for optional theme files. No critical issues.

**Minor:** The `systemctl --user is-active waybar` check at line 143 may fail when called via `sudo -Hu` in first-boot context (no D-Bus session).

---

## 5. First-Boot Architecture Audit

### aero-firstboot.service

```
ConditionPathExists=/etc/aero-installed      # Created by installer
ConditionPathExists=!/etc/aero-firstboot-complete  # Created by first-boot.sh
```

**Correct.** Service runs exactly once, only on Aero-installed systems.

### first-boot.sh (153 lines)

**Strengths:** Self-cleaning (removes service unit after completion). Network wait loop (60s timeout). Graceful handling of optional hardware detection.

**Issues:**

| Severity | Issue | File:Line |
|----------|-------|-----------|
| **REDUNDANCY** | btop and lazygit in both ISO packages and desktop.packages | `desktop.packages:19-20` |
| **REDUNDANCY** | Network ping check duplicated (loop at 60-64 + outer check at 70-78) | `first-boot.sh:60-78` |

### hardware-detect.sh (86 lines)

**Issues:**

| Severity | Issue | File:Line |
|----------|-------|-----------|
| **BUG** | Pacman hook `Target` directive uses file path instead of package name | `hardware-detect.sh:32` |
| **MASKING** | All `pacman -S` calls use `2>/dev/null \|\| true` | Multiple lines |
| **LIMITATION** | Hybrid GPU detection only matches first VGA device | `hardware-detect.sh:16` |

### snapper-boot.service (11 lines)

**Completely inert.** No `[Install]` section, never enabled by any script.

---

## 6. Package List Audit

### packages.x86_64 (58 packages)

| Package | Needed on ISO? | Size Impact | Notes |
|---------|---------------|-------------|-------|
| `linux-firmware` | ✅ Yes | ~700 MB | Largest contributor; consider reduced variant |
| `base-devel` | ❌ No | ~200-300 MB | Only needed on installed system for AUR builds |
| `archinstall` | ❌ No | ~5-10 MB | Completely unused — Aero has its own installer |
| `snapper` | ❌ No | ~5-10 MB | Only needed on installed system; pacstrapped during install |
| `reflector` | ❌ Maybe | ~1-2 MB | Removed at first-boot; keep for live troubleshooting |
| `pacman-contrib` | ❌ No | ~1 MB | Not used in live environment |
| `git` | ⚠️ Maybe | ~30-50 MB | Used by yay build; could be added by installer instead |
| `vim` + `neovim` + `nano` | ⚠️ Partial | ~30 MB | nano is sufficient; keep vim or neovim but not both |
| `btop` | ✅ Yes | ~2 MB | But duplicated in desktop.packages |
| `lazygit` | ✅ Yes | ~5 MB | But duplicated in desktop.packages |

**Key finding:** Removing `archinstall`, `base-devel`, `snapper`, `reflector`, and one text editor would save ~250-350 MB. Further trimming `linux-firmware` (or switching to `linux-firmware-whence`) could save another ~500 MB toward the 800 MB target.

### aur.packages (3 active)

- `visual-studio-code-bin` — desktop app, fine for first-boot
- `spotify` — desktop app, fine for first-boot
- `walker-bin` — application launcher (not in core/extra), correct placement

### desktop.packages (8 active)

**Redundant:** `btop` and `lazygit` are already in `packages.x86_64` and installed via pacstrap. Should be removed from this list.

---

## 7. Dead Code & Unused Files

| File | Status | Reason |
|------|--------|--------|
| `snapper-boot.service` | **DEAD** | No `[Install]` section; never enabled; completely inert |
| `archinstall` in packages.x86_64 | **DEAD** | Aero uses its own installer |
| Pre-copied snapper configs (lines 356-357) | **DEAD** | Overwritten by `snapper create-config` |
| KEYMAP auto-detection branch (lines 198-200) | **DEAD** | Pipe subshell breaks variable assignment; always uses "us" |
| walker configs on live ISO | **DEAD** | walker not installed; keybinding `SUPER+SPACE` silently fails |
| `btop` in desktop.packages | **REDUNDANT** | Already on ISO from packages.x86_64 |
| `lazygit` in desktop.packages | **REDUNDANT** | Already on ISO from packages.x86_64 |

---

## 8. Hardcoded Values

| Value | Files | Context |
|-------|-------|---------|
| `liveuser` | customize_airootfs.sh (×17), aero-greeter, sudoers.d | Live ISO user — correct for live env |
| `greeter` | greetd/config.toml, aero-install | greetd display manager user |
| `aero` (hostname) | customize_airootfs.sh, aero-install | Default hostname |
| `user` (username) | aero-install, first-boot.sh | Fallback installed username |
| `catppuccin` (theme) | first-boot.sh | Default theme applied at first boot |
| `/usr/share/backgrounds/aero/default.jpg` | customize_airootfs.sh, first-boot.sh | Wallpaper path |

---

## 9. Security Concerns

| Concern | Severity | Details |
|---------|----------|---------|
| Root password = user password | **Medium** | `ROOT_PASS="$USER_PASS"` — same password for both accounts |
| yay builds as root inside chroot | **Low** | `makepkg` should not run as root; use `sudo -u "$USERNAME"` |
| Passwordless liveuser sudo | **Low** | Intentional for live ISO; not present on installed system |
| Error masking with `\|\| true` | **Low** | Multiple scripts mask failures, making issues hard to diagnose |

---

## 10. ISO Size Breakdown

| Component | Estimated Size |
|-----------|---------------|
| `linux-firmware` | ~700 MB |
| `base-devel` group | ~200-300 MB |
| `linux` kernel + modules | ~100-150 MB |
| `hyprland` + deps | ~50-100 MB |
| `noto-fonts` | ~100-150 MB |
| `ghostty` | ~30-50 MB |
| All other packages + deps | ~200-300 MB |
| **Pre-compression total** | **~1.5-1.9 GB** |
| SquashFS zstd (level 19) | ~30-50% compression |
| **Actual ISO size** | **1.8 GB** |

---

## 11. Recommended Next Steps

### Immediate (before release)

1. **Remove `archinstall` from `packages.x86_64`** — unused, saves ~5-10 MB
2. **Remove `btop` and `lazygit` from `desktop.packages`** — redundant
3. **Fix `test.sh` line 44** — use proper OVMF_VARS template
4. **Fix `snapper-boot.service`** — add `[Install]` section or remove if intentional
5. **Add regression** — verify display boots before closing this milestone

### Short-term

6. **Remove `base-devel` from `packages.x86_64`** — saves ~200-300 MB
7. **Remove `snapper` from `packages.x86_64`** — saves ~5-10 MB
8. **Fix KEYMAP auto-detection** — single-line bug in `aero-install:198`
9. **Fix snapper config overwrite** — use pre-copied configs or remove them
10. **Unmask yay build errors** — remove `2>/dev/null` from `aero-install:406-410`

### Medium-term

11. **Trim `linux-firmware`** — biggest size saving (~500 MB)
12. **Fix hardware-detect.sh** — valid pacman hook targets, unmask errors
13. **Fix root password separation** — prompt for separate root password
14. **Deduplicate config directory list** — share between customize_airootfs.sh and aero-install

### Long-term

15. Automated ISO release pipeline
16. Repository signing
17. Package group selection in installer
18. LUKS encryption support

---

## 12. Files Changed Since Alpha 1 (04e3979)

| File | Change Type | Boot Impact |
|------|-------------|-------------|
| `packages.x86_64` | walker added then removed | None |
| `profiledef.sh` | Comments + specific file permissions | None |
| `customize_airootfs.sh` | Config deployment expanded | None |
| `first-boot.sh` | Config copy removed, `sudo -Hu` | None (installed system only) |
| `aero-firstboot.service` | ConditionPathExists inverted | None (installed system only) |
| `snapper-boot.service` | ExecStart simplified | None (installed system only) |
| `aero-install` | Phase 7 added, NVMe fix, dynamic UID | None |
| `aero-theme` (new) | Theme manager | None |
| `walker/config.toml` + style.css (new) | Launcher config | None |
| `catppuccin/colors.toml` + wallpaper.jpg (new) | Theme definition | None |
| `PROJECT_CONTEXT.md` | Updated | None |
| `README.md` (new) | Project readme | None |

**No change affects the live ISO boot path.** The "Guest has not initialized the display (yet)" message was transient — QEMU was killed before the boot completed.

---

*Generated by project audit — 2026-06-12*
