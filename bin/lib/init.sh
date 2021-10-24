#!/bin/bash -uea
# vim: ts=4 sw=4 et

# ---- checks

check_vm() {
  todo "check if running inside vm"
}

check_su() {
  todo "check if we are super-user"
}

# ---- setup

# TODO move to own script... lib/init.sh, lib/colors.sh, lib/...

# TODO add debug mode (silent=false)

# check if build root is set, otherwise set current working directory
#[[ ! -v BUILD_ROOT ]] && BUILD_ROOT="${PWD}"
#[[ -v BUILD_ROOT ]] || BUILD_ROOT="${PWD}"
#[[ -v BUILD_ROOT ]] || echo "Error, environment var BUILD_ROOT is not set!" ; exit 1;
step "build root is '$BUILD_ROOT'"

# TODO abort if run from inside vm, run as root, or from wrong dir (must be inside project root)

# TODO check location: ensure path exists and is a directory
#[[ -d "${BUILD_ROOT}" ]] || error "Not a directory or not existant: '${BUILD_ROOT}'"; exit 1
#echo "OK"

# TODO check location: ensure we are not '.' or '..'

# TODO check location: ensure we are not in '/'

# TODO check location: ensure it is a reasonable named dir with reasonable dir depth

# set dir paths
BUILD_SCRIPT_DIR="${BUILD_ROOT}/bin"  #"${BUILD_ROOT}/bin"
BUILD_LIB_DIR="${BUILD_SCRIPT_DIR}/lib"
BUILD_ETC_DIR="${BUILD_ROOT}/etc"
BUILD_DIR="${BUILD_ROOT}/build"

# various configs or artefacts
BUILD_ETC_DISTFILESLIST="${BUILD_ETC_DIR}/distfiles.list"
BUILD_ETC_ROOTCA="${BUILD_ETC_DIR}/rootCA.pem"
BUILD_ETC_ROOTCA_KEY="${BUILD_ETC_DIR}/rootCA-key.pem"
BUILD_ETC_VAGRANT_TOKEN="${BUILD_ETC_DIR}/vagrant-cloud-token"
BUILD_ETC_VERSION="${BUILD_ETC_DIR}/version"

# files created during building
BUILD_PATH_BUILD_NUMBER="${BUILD_DIR}/build_number"
BUILD_PATH_BUILD_TIME="${BUILD_DIR}/build_time"
BUILD_PATH_BUILD_VERSION="${BUILD_DIR}/build_version"
BUILD_PATH_PACKER_LOG="${BUILD_DIR}/packer.log"
BUILD_PATH_PACKER_CHECKSUM="${BUILD_DIR}/packer.sha1.checksum"
