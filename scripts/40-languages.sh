#!/bin/bash -uex

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- Java

# TODO + ant

# ---- JavaScript / node.js

sudo emerge -nuvtND --with-bdeps=y \
    net-libs/nodejs

# ---- PHP

# PHP and some tools/exts, see: https://wiki.gentoo.org/wiki/PHP
sudo emerge -nuvtND --with-bdeps=y \
    dev-lang/php \
    dev-php/xdebug \
    dev-php/composer \
    dev-php/pecl-oauth \
    dev-php/igbinary

# extensions:
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-taint dev-php/pecl-memcached
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-geoip dev-php/pecl-timezonedb
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-yaml dev-php/pecl-raphf dev-php/pecl-mailparse dev-php/pecl-event dev-php/pecl-eio dev-php/pecl-redis
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-http
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-amqp
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-stomp
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-apcu dev-php/pecl-apcu_bc

# update PEAR/PECL channels while online
#sudo emerge -v --config PEAR-PEAR

# ---- Python

# TODO add pip or more stuff?

# ----- Go

# TODO if needed by tooling

# ---- Sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
