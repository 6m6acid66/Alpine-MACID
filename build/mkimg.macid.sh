# MACID OS image profile.
# This profile starts from Alpine's official standard image profile.
profile_macid() {
  profile_standard

  title="MACID OS"
  desc="MACID OS: an Alpine Linux based x86_64 live system."
  profile_abbrev="macid"
  image_name="MACID OS"
  output_filename="MACID-${RELEASE}-${ARCH}.iso"
  hostname="macid"
  apkovl="genapkovl-macid.sh"

  # Use a temporary key for the local APK index. Do not require Alpine's
a  # private release key to sign the kernel module loop.
  modloop_sign=no

  # These packages are placed in the ISO's local APK repository for expansion.
  # The first boot remains intentionally small until the base is verified.
  apks="$apks
    bash
    curl
    git
    htop
    nano
    nmap
    openssh
    python3
    py3-pip
    tmux
    zsh
  "
}

# Give the BIOS boot menu MACID identity.
syslinux_gen_config() {
  echo "TIMEOUT 50"
  echo "PROMPT 0"
  echo "DEFAULT lts"
  echo "MENU TITLE MACID OS"
  cat <<EOF
LABEL lts
  MENU LABEL MACID OS (Live)
  KERNEL /boot/vmlinuz-lts
  INITRD /boot/initramfs-lts
  APPEND $initfs_cmdline $kernel_cmdline
EOF
}

# Give the UEFI boot menu MACID identity.
grub_gen_config() {
  cat <<EOF
set timeout=5
set default=0
menuentry "MACID OS (Live)" {
  linux /boot/vmlinuz-lts $initfs_cmdline $kernel_cmdline
  initrd /boot/initramfs-lts
}
EOF
}
