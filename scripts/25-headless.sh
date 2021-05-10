#!/bin/bash -uex

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- Run in headless mode?

if [ -z ${BUILD_HEADLESS:-} ]; then
    echo "BUILD_HEADLESS was not set. Skipping ..."
    exit 0
else
    if [ "$BUILD_HEADLESS" = false ]; then
        echo ">>> Skipping headless."
        exit 0
    else
        echo ">>> Preparing headless ..."
    fi
fi

# uninstall X11 stuff
sudo sed -i 's:app-editors/gvim::g' /var/lib/portage/world
sudo sed -i 's:app-editors/leafpad::g' /var/lib/portage/world
sudo sed -i 's:gnome-extra/nm-applet::g' /var/lib/portage/world
sudo sed -i 's:media-gfx/feh::g' /var/lib/portage/world
sudo sed -i 's:media-sound/pamix::g' /var/lib/portage/world
sudo sed -i 's:media-sound/paprefs::g' /var/lib/portage/world
sudo sed -i 's:media-sound/pasystray::g' /var/lib/portage/world
sudo sed -i 's:media-sound/pavucontrol::g' /var/lib/portage/world
sudo sed -i 's:media-sound/pavumeter::g' /var/lib/portage/world
sudo sed -i 's:media-sound/pulseaudio::g' /var/lib/portage/world
sudo sed -i 's:net-vpn/networkmanager-openvpn::g' /var/lib/portage/world
sudo sed -i 's:sys-auth/elogind::g' /var/lib/portage/world
sudo sed -i 's:x11-apps/mesa-progs::g' /var/lib/portage/world
sudo sed -i 's:x11-apps/xinit::g' /var/lib/portage/world
sudo sed -i 's:x11-base/xorg-x11::g' /var/lib/portage/world
sudo sed -i 's:x11-drivers/xf86-video-vmware::g' /var/lib/portage/world
sudo sed -i 's:x11-misc/lightdm::g' /var/lib/portage/world
sudo sed -i 's:x11-terms/xterm::g' /var/lib/portage/world
sudo sed -i 's:x11-themes/fluxbox-styles-fluxmod::g' /var/lib/portage/world
sudo sed -i 's:x11-wm/fluxbox::g' /var/lib/portage/world

# set profiles
sudo epro mix-ins -X -gnome

# remove use flag tweaks from previous boxes
sudo rm -f /etc/portage/package.use/base-gnome
sudo rm -f /etc/portage/package.use/base-audio
sudo rm -f /etc/portage/package.use/base-xorg
sudo rm -f /etc/portage/package.use/webdev-lasa-plugins

# modify use flags
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-headless
net-analyzer/wireshark -qt5 tfshark
media-video/ffmpeg -sdl -xvid
DATA

# remove packages
sudo emerge --depclean

# ---- Sync packages

#sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
#sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
