#!/bin/bash -uex

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

# ---- etckeeper

# see: https://etckeeper.branchable.com/
#sudo emerge -nuvtND --with-bdeps=y sys-apps/etckeeper
#sudo etckeeper init -d /etc

# ---- various version control systems (other than Git)

#sudo emerge -nuvtND --with-bdeps=y \
#  dev-vcs/subversion \
#  dev-vcs/mercurial \
#  dev-vcs/cvs

# TODO add 'dev-vcs/git-lfs' (last build failed)

# ---- various vim plugins

sudo emerge -nuvtND --with-bdeps=y \
  app-vim/bash-support \
  app-vim/vimpython \
  app-vim/vim-go \
  app-vim/rust-vim \
  app-vim/csv \
  app-vim/align \
  app-vim/ansiesc \
  app-vim/ant_menu \
  app-vim/closetag \
  app-vim/dhcpd-syntax \
  app-vim/editorconfig-vim \
  app-vim/eselect-syntax \
  app-vim/gentoo-syntax \
  app-vim/gist \
  app-vim/gitlog \
  app-vim/greputils \
  app-vim/json \
  app-vim/rails \
  app-vim/scala-syntax \
  app-vim/screen \
  app-vim/securemodelines \
  app-vim/surround \
  app-vim/tagbar \
  app-vim/taglist \
  app-vim/tasklist \
  app-vim/udev-syntax \
  app-vim/vcscommand \
  app-vim/vim-commentary \
  app-vim/vim-multiple-cursors \
  app-vim/vim-spell-de \
  app-vim/vim-spell-en \
  app-vim/vim-spell-fr \
  app-vim/vim-spell-pt \
  app-vim/vim-spell-nl \
  app-vim/vim-spell-pl \
  app-vim/vim-spell-cs \
  app-vim/vim-spell-da \
  app-vim/vim-spell-el \
  app-vim/vim-spell-es \
  app-vim/vim-spell-he \
  app-vim/vim-spell-hu \
  app-vim/vim-spell-it \
  app-vim/vimcommander \
  app-vim/vimoutliner \
  app-vim/wikipedia-syntax \
  app-vim/xsl-syntax \
  app-vim/webapi

# ---- various network utils

sudo emerge -nuvtND --with-bdeps=y \
  net-misc/aria2 \
  net-analyzer/tcpdump \
  net-misc/iperf \
  sys-apps/ethtool \
  net-dns/bind-tools \
  net-analyzer/iptraf-ng \
  net-analyzer/nmap \
  net-analyzer/openbsd-netcat \
  net-analyzer/iftop \
  net-dns/dnstop \
  net-analyzer/dnstracer \
  net-analyzer/dhcpdump \
  net-analyzer/traceroute \
  net-analyzer/snort \
  net-analyzer/wireshark \
  net-analyzer/mtr \
  net-misc/httpie \
  net-misc/geoipupdate \
  net-analyzer/tsung \
  net-misc/keychain

# install 'minica' in GOPATH
sudo GOPATH="/opt/go" go get github.com/jsha/minica

# ---- various file utils

sudo emerge -nuvtND --with-bdeps=y \
  app-misc/colordiff \
  sys-fs/inotify-tools \
  app-misc/icdiff \
  sys-apps/ripgrep \
  app-arch/pigz \
  app-text/multitail \
  app-misc/jq \
  sys-process/iotop \
  app-editors/curses-hexedit

# FIXME app-shells/fzf no more in portage tree

# ---- gfx/video utils

sudo emerge -nuvtND --with-bdeps=y \
    media-gfx/imagemagick \
    media-gfx/graphviz \
    app-text/ghostscript-gpl \
    media-video/ffmpeg \
    media-video/rtmpdump

# PHP imagick ext:
sudo emerge -nuvtND --with-bdeps=y \
    dev-php/pecl-imagick

# ---- protobuf

#sudo emerge -nuvtND --with-bdeps=y \
#  dev-libs/protobuf \
#  dev-python/protobuf-python \
#  dev-libs/protobuf-c \
#  dev-java/protobuf-java \
#  dev-erlang/protobuffs \
#  dev-go/go-protobuf \
#  dev-ruby/google-protobuf

# ---- debugging / profiling / benchmark

#sudo emerge -nuvtND --with-bdeps=y \
#    sys-devel/gdb \
#    dev-util/strace \
#    dev-util/systemtap \
#    sys-apps/lnxhc \
#    app-admin/dio

sudo emerge -nuvtND --with-bdeps=y \
    dev-db/mysql-super-smack

# ---- Kerberos V

sudo emerge -nuvtND --with-bdeps=y \
    app-crypt/mit-krb5

# ---- Sync packages

sf_vagrant="`sudo df | grep vagrant | tail -1 | awk '{ print $6 }'`"
sudo rsync -urv /var/cache/portage/packages/* $sf_vagrant/packages/
