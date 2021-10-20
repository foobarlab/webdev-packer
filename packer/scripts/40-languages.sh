#!/bin/bash -uex
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- Python

sudo emerge -nuvtND --with-bdeps=y \
    dev-python/pip \
    dev-python/sphinx \
    dev-python/numpy

# ---- Ruby

# disable doc creation by default
cat <<'DATA' | sudo tee -a /etc/gemrc
# if you do not want ruby docs or rake
#gem: --no-rdoc --no-ri
# or
#gem: --no-document

gem: --no-rdoc --no-ri

DATA

sudo emerge -nuvtND --with-bdeps=y \
    dev-lang/ruby \
    dev-ruby/rubygems \
    dev-ruby/bundler \
    dev-ruby/sass

# ---- Java

sudo emerge -nuvtND --with-bdeps=y \
    dev-java/openjdk-bin:8 \
    app-eselect/eselect-java \
    dev-java/ant \
    dev-java/ant-contrib \
    dev-java/ant-commons-net \
    dev-java/openjdk-bin \
    dev-java/ant-ivy \
    dev-java/maven-bin

# set default java system vm
sudo eselect java-vm set system openjdk-bin-8
eselect java-vm show

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
    dev-php/xhprof \
    dev-php/igbinary

# TODO add dev-php/php-spx

# more extensions:
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-taint dev-php/pecl-memcached
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-geoip dev-php/pecl-timezonedb
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-yaml dev-php/pecl-raphf dev-php/pecl-mailparse dev-php/pecl-event dev-php/pecl-eio dev-php/pecl-redis
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-http
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-amqp
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-stomp
#sudo emerge -nuvtND --with-bdeps=y dev-php/pecl-apcu dev-php/pecl-apcu_bc

# update PEAR/PECL channels while online
#sudo emerge -v --config PEAR-PEAR

# ----- Go

sudo emerge -nuvtND --with-bdeps=y dev-lang/go

# Go apps in /opt/go:
sudo mkdir -p /opt/go
cat <<'DATA' | sudo tee -a /root/.bashrc
# we want our apps to be in /opt/go
export GOPATH=/opt/go
export PATH=$PATH:$GOPATH/bin

DATA
cat <<'DATA' | sudo tee -a /root/.zshrc
# we want our apps to be in /opt/go
export GOPATH=/opt/go
export PATH=$PATH:$GOPATH/bin

DATA
cat <<'DATA' | sudo tee -a ~vagrant/.bashrc
# include go apps installed by root to our PATH
export PATH=$PATH:/opt/go/bin

DATA
cat <<'DATA' | sudo tee -a ~vagrant/.zshrc
# include go apps installed by root to our PATH
export PATH=$PATH:/opt/go/bin

DATA

# ---- Elixir / Erlang OTP

sudo emerge -nuvtND --with-bdeps=y \
    dev-lang/elixir \
    dev-lang/erlang \
    dev-util/rebar-bin

# ---- sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
