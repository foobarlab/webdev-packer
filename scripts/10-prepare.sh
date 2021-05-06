#!/bin/bash -uex

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- import binary packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
mkdir -p $sf_vagrant/packages || true
sudo mkdir -p /var/cache/portage/packages || true
sudo rsync -urv $sf_vagrant/packages /var/cache/portage/
sudo chown -R root:root /var/cache/portage/packages
sudo find /var/cache/portage/packages/ -type d -exec chmod 755 {} +
sudo find /var/cache/portage/packages/ -type f -exec chmod 644 {} +
sudo chown root:portage /var/cache/portage/packages
sudo chmod 775 /var/cache/portage/packages

# ---- box name

echo "$BUILD_BOX_DESCRIPTION" >> ~vagrant/.release_$BUILD_BOX_NAME
sed -i 's/<br>/\n/g' ~vagrant/.release_$BUILD_BOX_NAME
sed -i 's/<a .*a>/'$BUILD_GIT_COMMIT_ID'/g' ~vagrant/.release_$BUILD_BOX_NAME

# ---- /etc/motd and /etc/issue

sudo rm -f /etc/motd
cat <<'DATA' | sudo tee -a /etc/motd

Funtoo Linux Vagrant Box (BUILD_BOX_USERNAME/BUILD_BOX_NAME) - release BUILD_BOX_VERSION build BUILD_TIMESTAMP

DATA
sudo sed -i 's/BUILD_BOX_NAME/'"$BUILD_BOX_NAME"'/g' /etc/motd
sudo sed -i 's/BUILD_BOX_USERNAME/'"$BUILD_BOX_USERNAME"'/g' /etc/motd
sudo sed -i 's/BUILD_BOX_VERSION/'"$BUILD_BOX_VERSION"'/g' /etc/motd
sudo sed -i 's/BUILD_TIMESTAMP/'"$BUILD_TIMESTAMP"'/g' /etc/motd
sudo cat /etc/motd

sudo rm -f /etc/issue
cat <<'DATA' | sudo tee -a /etc/issue
This is a Funtoo Linux Vagrant Box (BUILD_BOX_USERNAME/BUILD_BOX_NAME-BUILD_BOX_VERSION)

DATA
sudo sed -i 's/BUILD_BOX_VERSION/'$BUILD_BOX_VERSION'/g' /etc/issue
sudo sed -i 's/BUILD_BOX_NAME/'$BUILD_BOX_NAME'/g' /etc/issue
sudo sed -i 's/BUILD_BOX_USERNAME/'"$BUILD_BOX_USERNAME"'/g' /etc/issue
sudo cat /etc/issue

# ---- custom overlay

if [ "$BUILD_CUSTOM_OVERLAY" = true ]; then
	cd /var/git
	sudo mkdir -p overlay
	cd overlay
	# example: git clone --depth 1 -b development "https://github.com/foobarlab/foobarlab-overlay.git" ./foobarlab
	sudo git clone --depth 1 -b $BUILD_CUSTOM_OVERLAY_BRANCH "$BUILD_CUSTOM_OVERLAY_URL" ./$BUILD_CUSTOM_OVERLAY_NAME
	cd ./$BUILD_CUSTOM_OVERLAY_NAME
	# set default strategy:
	#sudo git config pull.rebase true  # merge
	sudo git config pull.ff only       # fast forward only (recommended)
	sudo chown -R portage.portage /var/git/overlay
	cat <<'DATA' | sudo tee -a /etc/portage/repos.conf/$BUILD_CUSTOM_OVERLAY_NAME
[DEFAULT]
main-repo = core-kit

[BUILD_CUSTOM_OVERLAY_NAME]
location = /var/git/overlay/BUILD_CUSTOM_OVERLAY_NAME
auto-sync = no
priority = 10
DATA
	sudo sed -i 's/BUILD_CUSTOM_OVERLAY_NAME/'"$BUILD_CUSTOM_OVERLAY_NAME"'/g' /etc/portage/repos.conf/$BUILD_CUSTOM_OVERLAY_NAME
fi

# ---- make.conf

cat <<'DATA' | sudo tee -a /etc/portage/make.conf
MAKEOPTS="BUILD_MAKEOPTS"

DATA
sudo sed -i 's/BUILD_MAKEOPTS/'"$BUILD_MAKEOPTS"'/g' /etc/portage/make.conf

# Shell
sudo sed -i 's/USE=\"/USE="bash-completion zsh-completion /g' /etc/portage/make.conf

# Generic
#sudo sed -i 's/USE=\"/USE="hscolour profile systemtap jit pgo pcntl pcre /g' /etc/portage/make.conf

# Java
sudo sed -i 's/USE=\"/USE="java jce /g' /etc/portage/make.conf

# Apache webserver
sudo sed -i 's/USE=\"/USE="apache2 /g' /etc/portage/make.conf
# apache modules/mpm
# TODO consider switching to mpm-event
cat <<'DATA' | sudo tee -a /etc/portage/make.conf
# Apache config, see: https://www.funtoo.org/Package:Apache
APACHE2_MODULES="actions alias auth_basic auth_digest authn_alias authn_anon authn_core authn_dbm authn_file authz_core authz_dbm authz_groupfile authz_host authz_owner authz_user autoindex cache cgi cgid dav dav_fs dav_lock deflate dir env expires ext_filter file_cache filter headers include info log_config logio mime mime_magic negotiation rewrite setenvif socache_shmcb speling status unique_id unixd userdir usertrack vhost_alias proxy proxy_fcgi"
APACHE2_MPMS="worker"

DATA

# Nginx
cat <<'DATA' | sudo tee -a /etc/portage/make.conf
# Nginx config
# see: https://www.funtoo.org/Package:Nginx
# see: https://wiki.gentoo.org/wiki/Nginx
NGINX_MODULES_HTTP="access auth_basic autoindex browser charset empty_gif fastcgi geo gzip limit_conn limit_req map memcached proxy realip referer rewrite scgi split_clients secure_link spdy ssi ssl upstream_hash upstream_ip_hash upstream_keepalive upstream_least_conn upstream_zone userid uwsgi"
NGINX_MODULES_EXTERNAL="accept_language cache_purge modsecurity upload_progress"

DATA

# PHP
sudo sed -i 's/USE=\"/USE="fpm php /g' /etc/portage/make.conf
# php targets
cat <<'DATA' | sudo tee -a /etc/portage/make.conf
# PHP_TARGETS / PHP_TARGETS USE_EXPAND will build extensions, see: https://wiki.gentoo.org/wiki/PHP
#PHP_TARGETS="php5-6 php7-0 php7-1 php7-2 php7-3 php7-4"
PHP_TARGETS="php7-3 php7-4"

DATA

# MySQL
sudo sed -i 's/USE=\"/USE="mysql /g' /etc/portage/make.conf

# PostgreSQL
sudo sed -i 's/USE=\"/USE="postgres /g' /etc/portage/make.conf

# Media
sudo sed -i 's/USE=\"/USE="imagemagick apng exif gif ico jpeg jpeg2k pdf png svg tiff truetype webp wmf mng pnm /g' /etc/portage/make.conf

sudo cat /etc/portage/make.conf

# ---- package.use

sudo mkdir -p /etc/portage/package.use
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-curl
#net-misc/curl rtmp http2 brotli    # FIXME 'http2' requires '-bindist'
net-misc/curl rtmp brotli
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-ghostscript
# required by openjdk:
#>=app-text/ghostscript-gpl-9.26 cups
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-avahi
net-dns/avahi dbus mdnsresponder-compat
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-java
# customize java-jre, make it headless, see: https://wiki.gentoo.org/wiki/Java
dev-java/oracle-jre-bin headless-awt -alsa -awt -cups -fontconfig
dev-java/oracle-jdk-bin headless-awt -alsa -awt -cups -fontconfig
dev-java/icedtea-bin headless-awt -gtk -alsa -cups -webstart -nsplugin
dev-java/openjdk headless-awt -alsa -cups -webstart
dev-java/openjdk-bin headless-awt -alsa -cups -webstart
dev-java/openjdk-jre-bin headless-awt -alsa -cups -webstart
dev-java/ant -javamail
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-apache
www-servers/apache ssl threads
# required by www-apache/mod_security www-apache/modsecurity-crs:
dev-libs/apr-util openssl
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-nginx
www-servers/nginx threads vim-syntax
DATA
#cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-redis
#dev-db/redis luajit
#DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-php
dev-lang/php curl pdo mysql mysqli xmlwriter xmlreader apache2 argon2 bcmath calendar cgi enchant flatfile fpm inifile mhash odbc postgres soap sockets sodium spell xmlrpc xslt zip zip-encryption sqlite phar opcache tidy xpm gmp ftp
# required by www-apps/postfixadmin:
>=dev-lang/php-5.6 imap
# various extensions: FIXME check for PHP 7.4 compatibility
dev-php/pecl-redis igbinary
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-erlang
>=dev-lang/erlang-22.3 hipe kpoll odbc sctp -wxwidgets -tk doc
DATA
#cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-kafka
## use embedded zookeeper for kafka:
#net-misc/kafka-bin internal-zookeeper
#DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-imagick
# customize gnome-base/librsvg (pulled by media-gfx/imagemagick): prevent emerge of X11
gnome-base/librsvg -tools
# customize media-gfx/imagemagick (required by dev-php/pecl-imagick):
media-gfx/imagemagick -openmp
# additional supported libs for imagick:
# FIXME 'heif' fails to compile
media-gfx/imagemagick -corefonts fontconfig graphviz jpeg2k postscript wmf raw hdri fpx lqr
# required by media-gfx/graphviz, dev-php/phpDocumentor, dev-php/phing:
media-libs/gd fontconfig
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-ffmpeg
media-video/ffmpeg -bluray -frei0r -ieee1394 cpudetection
DATA
#cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-wireshark
## customize wireshark:
#net-analyzer/wireshark -qt5 androiddump sshdump brotli tfshark adns lua smi
#DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-rust
dev-lang/rust clippy libressl rls rustfmt wasm
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-krb5
app-crypt/mit-krb5 keyutils libressl
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-ant
# FIXME temporary added here, pulls in jython (build failing)
dev-java/ant -bsf
DATA
cat <<'DATA' | sudo tee -a /etc/portage/package.use/webdev-alsa-plugins
# required by firefox-bin:
>=media-plugins/alsa-plugins-1.1.9 pulseaudio
DATA

# temporary fixes (removed in 90-postprocess.sh)
cat <<'DATA' | sudo tee -a /etc/portage/package.use/temp-circular-fix
# resolve circular dependency during install:
>=media-libs/libwebp-1.0.2 -tiff
>=media-libs/libjpeg-turbo-2.0.2 -java
DATA

# ---- package.license

sudo mkdir -p /etc/portage/package.license
cat <<'DATA' | sudo tee -a /etc/portage/package.license/webdev-libpng
# required by openjdk:
media-libs/libpng libpng2
DATA

# ---- package.mask

sudo mkdir -p /etc/portage/package.mask

# ---- package.unmask

sudo mkdir -p /etc/portage/package.unmask

# ---- package.accept_keywords

sudo mkdir -p /etc/portage/package.accept_keywords

# --- always copy kernel.config to current kernel src

sudo cp -f /usr/src/kernel.config /usr/src/linux/.config

# --- sync

sudo ego sync
sudo eclean packages

# ---- profile mix-ins

sudo epro list

user_id=$(id -u)    # FIX: because of "/etc/profile.d/java-config-2.sh: line 22: user_id: unbound variable" we try to set the variable here
sudo env-update
source /etc/profile
