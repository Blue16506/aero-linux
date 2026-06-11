# Aero Linux - TODO

## Completed

### Core ISO Profile

- [x] Create archiso profile directory structure
- [x] Create `packages.x86_64` with Ghostty, Hyprland, greetd, zsh, etc.
- [x] Create `profiledef.sh` with Limine bootmodes and file permissions
- [x] Create `pacman.conf` with core/extra repos
- [x] Create `build.sh` - ISO build wrapper

### System Configuration

- [x] Create `mkinitcpio.conf` with btrfs + LUKS hooks
- [x] Create `airootfs/etc/limine.conf` bootloader template (for installed system)
- [x] Create `airootfs/etc/greetd/config.toml` with tuigreet
- [x] Create `airootfs/etc/pam.d/greetd` - PAM config for greetd
- [x] Create `airootfs/etc/snapper/config-templates/root` - snapper root policy
- [x] Create `airootfs/etc/snapper/config-templates/home` - snapper home policy
- [x] Create `airootfs/etc/sudoers.d/aero-installer` - live env sudo rules
- [x] Create `airootfs/etc/pacman.d/mirrorlist` - package mirrors
- [x] Create `airootfs/etc/zsh/zshenv` - global zsh environment

### Systemd Services

- [x] Create `airootfs/etc/systemd/system/aero-firstboot.service`
- [x] Create `airootfs/etc/systemd/system/snapper-boot.service`

### Installer & First Boot

- [x] Create `airootfs/usr/local/bin/aero-install` - main interactive installer script
- [x] Create `airootfs/usr/share/aero/scripts/first-boot.sh` - first-boot setup
- [x] Create `airootfs/usr/share/aero/scripts/hardware-detect.sh` - GPU/CPU detection

### Live Environment

- [x] Create `airootfs/root/customize_airootfs.sh` - archiso post-build customization
- [x] Create `airootfs/root/.zshrc` - live environment shell config
- [x] Create `airootfs/root/.automated_script.sh` - auto-launch installer on boot
- [x] Create `airootfs/root/.config/starship.toml` - root prompt theme

### Desktop Configuration

- [x] Create modular Hyprland configs:
  - [x] `hyprland.conf` - main entry point (sources all modules)
  - [x] `monitors.conf` - auto-detect monitors
  - [x] `input.conf` - keyboard, touchpad, mouse
  - [x] `binds.conf` - keybindings (SUPER key)
  - [x] `appearance.conf` - animations, gaps, borders, Catppuccin colors
  - [x] `autostart.conf` - startup applications
  - [x] `windowrules.conf` - window rules per app
- [x] Create Waybar config:
  - [x] `config.jsonc` - bar layout with workspaces, clock, volume, etc.
  - [x] `style.css` - Catppuccin-themed bar styling
- [x] Create Ghostty config:
  - [x] `config` - Catppuccin Mocha colors, JetBrains Mono font, 0.92 opacity
- [x] Create zsh user config:
  - [x] `.zshrc` - main config sourcing modules
  - [x] `aliases.zsh` - eza, bat, ripgrep, git aliases
  - [x] `plugins.zsh` - autosuggestions, syntax-highlighting, zoxide
  - [x] `completion.zsh` - fzf, case-insensitive completions
  - [x] `keybindings.zsh` - vi mode, history search
  - [x] `theme.zsh` - starship initialization
- [x] Create mako notification config
- [x] Create wlogout power menu config (layout.json + style.css)
- [x] Create snapper configs for `/usr/share/aero/configs/snapper/`

### Branding & Packages

- [x] Create default wallpaper (Catppuccin gradient, 4K)
- [x] Create `airootfs/usr/share/aero/packages/aur.packages`
- [x] Create `airootfs/usr/share/aero/packages/desktop.packages`

### Project Documentation

- [x] Create `PROJECT_CONTEXT.md` with full project documentation
- [x] Create `TODO.md` task tracking

## Pending - High Priority

- [ ] Test ISO build with `sudo ./build.sh`
- [ ] Test installer in QEMU (UEFI and BIOS modes)
- [ ] Create `aero-theme` CLI script for theme switching
- [ ] Create Catppuccin Mocha theme definition
- [ ] Create walker/rofi launcher config

## Pending - Medium Priority

- [ ] Bluetooth auto-configuration
- [ ] NetworkManager iwd backend integration
- [ ] Firewall (ufw) pre-configuration
- [ ] `aero-update` script with pre/post snapper snapshots
- [ ] Kernel selection (linux-zen, linux-lts)

## Future Enhancements

- [ ] Plymouth boot splash with branding
- [ ] LUKS encryption support in installer
- [ ] NVIDIA GPU auto-detection and driver installation
- [ ] Printer support
- [ ] Virtual machine guest tools
- [ ] Package group selection in installer
- [ ] Automated ISO release pipeline
- [ ] Repository signing
- [ ] Custom wallpapers pack

## Notes

- All desktop configs live in `/usr/share/aero/configs/` and are copied to `~/.config/` during first boot
- `aero-firstboot.service` is a oneshot systemd service that removes itself after completion
- Limine handles both UEFI and BIOS boot paths (declared in profiledef.sh)
- greetd + tuigreet provide a lightweight TTY-based login (no X11 display manager)
- Snapper configured for root (`@`) and home (`@home`) subvolumes
- Target ISO size: ~800MB (minimal); desktop and AUR install at first boot via network
- The limine package must be installed on the host to build (checked in build.sh)
- Installer writes `/etc/aero-install.conf` during installation for first-boot to read
