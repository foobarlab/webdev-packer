#!/bin/bash -uex
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

if [ -z ${BUILD_KERNEL:-} ]; then
  echo "BUILD_KERNEL was not set. Skipping kernel build."
  exit 0
else
  if [ "$BUILD_KERNEL" = false ]; then
    echo ">>> Skipping kernel build."
    exit 0
  else
    echo ">>> Building kernel ..."
  fi
fi

# ---- copy kernel config

if [ -f ${scripts}/scripts/kernel.config ]; then
  if [ -f /usr/src/kernel.config ]; then
    KERNEL_RELEASE=$(uname -r)
    sudo mv -f /usr/src/kernel.config /usr/src/kernel.config.${KERNEL_RELEASE}
  fi
  sudo cp ${scripts}/scripts/kernel.config /usr/src
fi

# ---- list installed kernels

sudo eclean-kernel -l
sudo eselect kernel list

# ---- prepare new kernel

sudo emerge -vt sys-kernel/debian-sources

sudo eselect kernel list
sudo eselect kernel set 1
sudo eselect kernel list
sudo eclean-kernel -l

# ---- configure kernel

cd /usr/src/linux

# apply 'make olddefconfig' on 'kernel.config' in case kernel config is outdated
sudo cp -f /usr/src/kernel.config /usr/src/kernel.config.bak
sudo mv -f /usr/src/kernel.config /usr/src/linux/.config
sudo make olddefconfig
sudo mv -f /usr/src/linux/.config /usr/src/kernel.config
sudo cp -f /usr/src/kernel.config /usr/src/kernel.config.base

# TODO set MAKEOPTS in genkernel.conf to BUILD_MAKEOPTS?

# ---- build kernel

sudo genkernel all
cd /usr/src

# ---- update environment

user_id=$(id -u)    # FIX: because of "/etc/profile.d/java-config-2.sh: line 22: user_id: unbound variable" we try to set the variable here
sudo env-update
source /etc/profile

# ---- update boot

sudo mv /etc/boot.conf /etc/boot.conf.old
cat <<'DATA' | sudo tee -a /etc/boot.conf
boot {
  generate grub
  default "Funtoo Linux"
  timeout 1
}
display {
  gfxmode 800x600
}
"Funtoo Linux" {
  kernel kernel[-v]
  initrd initramfs[-v]
  params += root=auto rootfstype=auto
}
DATA

sudo ego boot update
