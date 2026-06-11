# Aero Linux - archiso profile definition

iso_name="aero-linux"
iso_label="AERO_$(date +%Y%m)"
iso_publisher="Aero Linux <https://github.com/aero-linux>"
iso_application="Aero Linux Live/Install ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="aero"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/sudoers.d/aero-installer"]="0:0:440"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.config/starship.toml"]="0:0:644"
  ["/usr/local/bin/aero-install"]="0:0:755"
  ["/usr/local/bin/aero-greeter"]="0:0:755"
  ["/usr/share/aero/packages/"]="0:0:644"
  ["/usr/share/aero/configs/"]="0:0:644"
  ["/usr/share/aero/scripts/"]="0:0:755"
  ["/usr/share/backgrounds/aero/"]="0:0:644"
)