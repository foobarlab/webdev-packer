#!/bin/bash -uex

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# TODO disable 'sendfile' option in any webserver, see https://www.vagrantup.com/docs/synced-folders/virtualbox#caveats

# ---- Apache

sudo emerge -nuvtND --with-bdeps=y \
    www-servers/apache \
    app-admin/apachetop

# add some more (optional) modules
#sudo emerge -nuvtND --with-bdeps=y \
#  www-apache/mod_bw \
#  www-apache/mod_common_redirect \
#  www-apache/mod_dnsbl_lookup \
#  www-apache/mod_evasive \
#  www-apache/mod_fcgid \
#  www-apache/mod_geoip2 \
#  www-apache/mod_limitipconn \
#  www-apache/mod_log_sql \
#  www-apache/mod_qos \
#  www-apache/mod_umask \
#  www-apache/mod_xsendfile

# TODO: add mod_security
#sudo emerge -nuvtND --with-bdeps=y www-apache/mod_security www-apache/modsecurity-crs

# TESTING:
#sudo emerge -nuvtND --with-bdeps=y www-apache/mod_dnssd www-apache/mod_tidy

# set global server name to avoid annoying warning message on startup
cat <<'DATA' | sudo tee -a /etc/apache2/httpd.conf

# apache global server name:
ServerName BUILD_BOX_NAME

DATA
sudo sed -i 's/BUILD_BOX_NAME/'"$BUILD_BOX_NAME"'/g' /etc/apache2/httpd.conf

# set some DEFINE flags to enable stuff:
#  AUTH_DIGEST  Enables mod_auth_digest
#  AUTHNZ_LDAP  Enables authentication through mod_ldap (available if USE=ldap)
#  CACHE        Enables mod_cache
#  DAV          Enables mod_dav
#  ERRORDOCS    Enables default error documents for many languages.
#  INFO         Enables mod_info, a useful module for debugging
#  LANGUAGE     Enables content-negotiation based on language and charset.
#  LDAP         Enables mod_ldap (available if USE=ldap)
#  MANUAL       Enables /manual/ to be the apache manual (available if USE=docs)
#  MEM_CACHE    Enables default configuration mod_mem_cache
#  PROXY        Enables mod_proxy
#  SSL          Enables SSL (available if USE=ssl)
#  STATUS       Enabled mod_status, a useful module for statistics
#  SUEXEC       Enables running CGI scripts (in USERDIR) through suexec.
#  USERDIR      Enables /~username mapping to /home/username/public_html

sudo grep -e '-D LANGUAGE' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D LANGUAGE"/g' /etc/conf.d/apache2
sudo grep -e '-D PHP' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D PHP"/g' /etc/conf.d/apache2
sudo grep -e '-D SECURITY' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D SECURITY"/g' /etc/conf.d/apache2
sudo grep -e '-D PROXY' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D PROXY"/g' /etc/conf.d/apache2
sudo grep -e '-D STATUS' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D STATUS"/g' /etc/conf.d/apache2
sudo grep -e '-D ERRORDOCS' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D ERRORDOCS"/g' /etc/conf.d/apache2
sudo grep -e '-D AUTH_DIGEST' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D AUTH_DIGEST"/g' /etc/conf.d/apache2
sudo grep -e '-D CACHE' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D CACHE"/g' /etc/conf.d/apache2
sudo grep -e '-D FCGID' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D FCGID"/g' /etc/conf.d/apache2
#sudo grep -e '-D DNSSD' /etc/conf.d/apache2 > /dev/null || sudo sed -ir 's/APACHE2_OPTS="\(.*\)"/APACHE2_OPTS="\1 -D DNSSD"/g' /etc/conf.d/apache2 # TESTING

# hint: https://wiki.gentoo.org/wiki/Project:Apache/Troubleshooting
# hint: https://wiki.gentoo.org/wiki/Project:Apache/Upgrading

#sudo rc-update add apache2 default

# ---- Nginx

# workaround: deps needed for nginx install
sudo emerge -nuvtND --with-bdeps=y \
  media-libs/gd \
  dev-libs/geoip

sudo emerge -nuvtND --with-bdeps=y \
  www-servers/nginx \
  app-admin/ngxtop

# ---- Lighttpd

sudo emerge -nuvtND --with-bdeps=y \
    www-servers/lighttpd

# ---- Let's encrypt

sudo emerge -nuvtND --with-bdeps=y \
  app-crypt/certbot \
  app-crypt/certbot-apache \
  app-crypt/certbot-nginx

# ---- Varnish proxy cache

sudo emerge -nuvtND --with-bdeps=y \
  net-proxy/varnish

# FIXME install net-proxy/varnish-modules

# ---- DNSmasq

sudo emerge -nuvtND --with-bdeps=y \
    net-dns/dnsmasq

#sudo rc-update add dnsmasq default

# ---- Postfix

sudo emerge -nuvtND --with-bdeps=y \
    mail-mta/postfix

# ---- Avahi / mDNS

sudo emerge -nuvtND --with-bdeps=y \
  net-dns/avahi \
  sys-auth/nss-mdns \
  dev-python/zeroconf

# ---- Sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
