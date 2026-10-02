#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Rename the OS shown on screen (GRUB menu, Settings > About, fastfetch) to Sancio
for f in /usr/lib/os-release /etc/os-release; do
  [ -f "$f" ] || continue
  sed -i 's/^NAME=.*/NAME="Sancio"/; s/^PRETTY_NAME=.*/PRETTY_NAME="Sancio"/' "$f"
done

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux \
  git htop fastfetch vim ripgrep fd nano \
  tailscale \
  distrobox fuse-sshfs evtest \
  plymouth-theme-charge \
  kitty btop vlc gnome-tweaks timeshift

plymouth-set-default-theme charge
cp -f /ctx/penguin_head.png /usr/share/plymouth/themes/charge/watermark.png
dracut --regenerate-all --force

### GDM login screen customization

# Login logo (org.gnome.login-screen.logo)
mkdir -p /etc/dconf/db/gdm.d
cp -f /ctx/penguin_head.png /usr/share/pixmaps/penguin_head.png
cp -f /ctx/gdm/01-logo /etc/dconf/db/gdm.d/01-logo

# Login background via GNOME Shell extension
cp -f /ctx/wallpaper.png /usr/share/backgrounds/wallpaper.png
mkdir -p /usr/share/gnome-shell/extensions/gdm-wallpaper@sancioos
cp -f /ctx/gdm-wallpaper-extension/extension.js /usr/share/gnome-shell/extensions/gdm-wallpaper@sancioos/
cp -f /ctx/gdm-wallpaper-extension/metadata.json /usr/share/gnome-shell/extensions/gdm-wallpaper@sancioos/

# Enable the extension for GDM
sudo -u gdm dbus-launch gsettings set org.gnome.shell enabled-extensions "['gdm-wallpaper@sancioos']" || true
dconf update

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable tailscaled.service
