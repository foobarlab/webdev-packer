#!/bin/bash -uex
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# TODO split into separate files: email dns, search-index, message-queue, ...

# ---- Postfix

sudo emerge -nuvtND --with-bdeps=y \
    mail-mta/postfix

# ---- Redis

sudo emerge -nuvtND --with-bdeps=y \
    dev-db/redis

# ---- Solr

sudo emerge -nuvtND --with-bdeps=y \
    dev-db/apache-solr-bin

# ---- RabbitMQ

sudo emerge -nuvtND --with-bdeps=y \
    net-misc/rabbitmq-server

# ---- Sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
