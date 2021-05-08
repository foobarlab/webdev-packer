#!/bin/bash -uex

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- various webtools

sudo emerge -nuvtND --with-bdeps=y \
    app-admin/webapp-config \
    www-misc/shellinabox \
    dev-db/phpmyadmin \
    www-apps/phpsysinfo \
    www-apps/postfixadmin

# ---- Sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
