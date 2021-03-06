#!/bin/bash -uea
# vim: ts=4 sw=4 et

# ---- checks

[[ "$EUID" -eq 0 ]] && { error "You can not run this script as 'root' user!"; exit 1; }

# ---- setup

# debug mode?
if [[ -v BUILD_DEBUG ]]; then
  if [[ "$BUILD_DEBUG" == "false" ]]; then
    silent=true
  else
    silent=false
  fi
fi

# check if build root is set, otherwise set current working directory
[[ -v BUILD_ROOT ]] || BUILD_ROOT="${PWD}"

# TODO check location: ensure path exists and is a directory
[[ -d "${BUILD_ROOT}" ]] || { error "Not a directory or not existant: '${BUILD_ROOT}'"; exit 1; }
step "build root is '$BUILD_ROOT'"

# set dir paths
BUILD_DIR_BIN="${BUILD_ROOT:-.}/bin"
BUILD_DIR_LIB="${BUILD_DIR_BIN}/lib"
BUILD_DIR_ETC="${BUILD_ROOT:-.}/etc"
BUILD_DIR_BUILD="${BUILD_ROOT:-.}/build"
BUILD_DIR_PACKER="${BUILD_ROOT:-.}/packer"
BUILD_DIR_KEYS="${BUILD_ROOT:-.}/keys"
BUILD_DIR_PACKAGES="${BUILD_ROOT:-.}/packages"
BUILD_DIR_DISTFILES="${BUILD_ROOT:-.}/distfiles"

# bin files
BUILD_BIN_CONFIG="${BUILD_DIR_BIN}/config.sh"
BUILD_LIB_UTILS="${BUILD_DIR_LIB}/utils.sh"

# packer provisioner
BUILD_FILE_PACKER_HCL="${BUILD_DIR_PACKER}/virtualbox.pkr.hcl"
BUILD_FILE_PACKER_LOG="${BUILD_DIR_BUILD}/packer.log"
#BUILD_FILE_PACKER_CHECKSUM="${BUILD_DIR_BUILD}/packer.sha1.checksum"

# config files
BUILD_FILE_DISTFILESLIST="${BUILD_DIR_ETC}/distfiles.list"
BUILD_FILE_VERSIONFILE="${BUILD_DIR_ETC}/version"

  BUILD_FILE_ROOTCA="rootCA.pem"
  BUILD_FILE_ROOTCA_KEY="rootCA-key.pem"
BUILD_FILE_VAGRANT_TOKEN="${BUILD_ROOT}/vagrant-cloud-token"

# files created during build
BUILD_FILE_BUILD_NUMBER="${BUILD_DIR_BUILD}/build_number"
BUILD_FILE_BUILD_TIME="${BUILD_DIR_BUILD}/build_time"
BUILD_FILE_BUILD_VERSION="${BUILD_DIR_BUILD}/build_version"
