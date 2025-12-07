#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

# Remove Steam/Lutris
dnf5 -y remove \
    gamescope.x86_64 \
    gamescope-libs.x86_64 \
    gamescope-libs.i686 \
    gamescope-shaders \
    jupiter-sd-mounting-btrfs \
    umu-launcher \
    dbus-x11 \
    xdg-user-dirs \
    gobject-introspection \
    libFAudio.x86_64 \
    libFAudio.i686 \
    vkBasalt.x86_64 \
    vkBasalt.i686 \
    mangohud.x86_64 \
    mangohud.i686 \
    libobs_vkcapture.x86_64 \
    libobs_glcapture.x86_64 \
    libobs_vkcapture.i686 \
    libobs_glcapture.i686 \
    VK_hdr_layer

rm -rf /usr/bin/winetricks
