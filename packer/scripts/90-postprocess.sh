#!/bin/bash -uex
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- sanitize perl packages

sudo perl-cleaner --all

# ---- remove any temp portage flags and update system

for dir in /etc/portage/package.*; do
  sudo rm -f /etc/portage/${dir##*/}/temp*
done
sudo emerge -vtuDN --with-bdeps=y --complete-graph=y @world

## net-mail/mailbase: adjust permissions as recommended during install
#sudo chown root:mail /var/spool/mail/
#sudo chmod 03775 /var/spool/mail/

# sys-apps/mlocate: add shared folder (usually '/vagrant') to /etc/updatedb.conf prune paths to avoid leaking shared files
sudo sed -i 's/PRUNEPATHS="/PRUNEPATHS="\/srv \/data \/vagrant /g' /etc/updatedb.conf

# sanitize golang packages
sudo emerge -vt @golang-rebuild
