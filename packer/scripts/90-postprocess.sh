#!/bin/bash -uex
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- sanitize perl packages

sudo perl-cleaner --all

# ---- remove any temp portage flags

for dir in /etc/portage/package.*; do
  sudo rm -f /etc/portage/${dir##*/}/temp*
done

# ---- mail permissions
# net-mail/mailbase: adjust permissions as recommended during install

sudo chown root:mail /var/spool/mail/
sudo chmod 03775 /var/spool/mail/

# ---- sys-apps/mlocate
# add shared folder (usually '/vagrant') to /etc/updatedb.conf prune paths to avoid leaking shared files

sudo sed -i 's/PRUNEPATHS="/PRUNEPATHS="\/srv \/data \/vagrant /g' /etc/updatedb.conf

# ---- update world

sudo /usr/local/sbin/foo-sync || sudo ego sync
sudo emerge -vtuDN --with-bdeps=y --complete-graph=y @world

# ---- sanitize golang packages

sudo emerge -vt @golang-rebuild

# ---- check consistency

sudo emerge -vt @preserved-rebuild
sudo emerge --depclean
sudo emerge -vt @preserved-rebuild
sudo revdep-rebuild

# ---- sync any guest packages to host (via shared folder)

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/

