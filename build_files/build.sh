#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Rename the OS shown on screen (GRUB menu, Settings > About, fastfetch) to SancioOs
for f in /usr/lib/os-release /etc/os-release; do
  [ -f "$f" ] || continue
  sed -i 's/^NAME=.*/NAME="SancioOs"/; s/^PRETTY_NAME=.*/PRETTY_NAME="SancioOs"/; s/^ID=.*/ID=sancioos/' "$f"
done

# Show "SancioOs" in the GRUB menu and regenerate its config
echo 'GRUB_DISTRIBUTOR="SancioOs"' > /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true

### GDM login screen customization

# Login logo (org.gnome.login-screen.logo)
mkdir -p /etc/dconf/db/gdm.d
cp -f /ctx/penguin_head.png /usr/share/pixmaps/penguin_head.png
cp -f /ctx/gdm/01-logo /etc/dconf/db/gdm.d/01-logo
cp -f /ctx/gdm/02-wallpaper-extension /etc/dconf/db/gdm.d/02-wallpaper-extension

# Login background via GNOME Shell extension
cp -f /ctx/wallpaper.png /usr/share/backgrounds/wallpaper.png
mkdir -p /usr/share/gnome-shell/extensions/gdm-wallpaper@sancioos
cp -f /ctx/gdm-wallpaper-extension/extension.js /usr/share/gnome-shell/extensions/gdm-wallpaper@sancioos/
cp -f /ctx/gdm-wallpaper-extension/metadata.json /usr/share/gnome-shell/extensions/gdm-wallpaper@sancioos/

# Apply the GDM dconf database
dconf update
