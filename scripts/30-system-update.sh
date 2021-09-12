#!/bin/bash -uex
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

sudo emerge -vtuDN --with-bdeps=y --complete-graph=y @world

sudo emerge -vt @preserved-rebuild

sudo emerge --depclean

sudo emerge -vt @preserved-rebuild

# remove known obsolete config files
sudo rm -f /etc/conf.d/._cfg0000_hostname
sudo rm -f /etc/conf.d/._cfg0000_consolefont

sudo find /etc/ -name '._cfg*'        # DEBUG: list all config files needing an update
sudo find /etc/ -name '._cfg*' -print -exec cat -n '{}' \;  # DEBUG: cat all config files needing an update

sudo etc-update --verbose --preen    # auto-merge trivial changes

# DEBUG:
eselect java-vm list

# TODO is this needed?
#user_id=$(id -u)    # FIX: because of "/etc/profile.d/java-config-2.sh: line 22: user_id: unbound variable" we try to set the variable here
#sudo env-update
#source /etc/profile

# show updated packages
sudo genlop -u -l

# ---- Sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
