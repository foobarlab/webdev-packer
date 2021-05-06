#!/bin/bash -uex

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# refresh fluxbox menu
fluxbox-generate_menu -is -ds

# sanitize perl packages
sudo perl-cleaner --all

# remove any temp portage flags and update system
for dir in /etc/portage/package.*; do
  sudo rm -f /etc/portage/${dir##*/}/temp*
done
sudo emerge -vtuDN --with-bdeps=y @world

# net-mail/mailbase: adjust permissions as recommended during install
sudo chown root:mail /var/spool/mail/
sudo chmod 03775 /var/spool/mail/

# sys-apps/mlocate: add shared folders to /etc/updatedb.conf prune paths to avoid leaking shared files
sudo sed -i 's/PRUNEPATHS="/PRUNEPATHS="\/srv \/data /g' /etc/updatedb.conf

sudo emerge -vt @preserved-rebuild

# check dynamic linking consistency
sudo revdep-rebuild
