#!/bin/bash -uex
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- various webtools

sudo emerge -nuvtND --with-bdeps=y \
    app-admin/webapp-config \
    www-misc/shellinabox \
    www-apps/phpsysinfo \
    www-apps/postfixadmin \
    dev-db/phppgadmin

# FIXME
#dev-db/phpmyadmin \

# ---- Sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
