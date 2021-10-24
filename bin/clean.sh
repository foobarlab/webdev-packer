#!/bin/bash -ue
# vim: ts=4 sw=4 et

source "${BUILD_ROOT}/bin/config.sh" quiet

title "CLEANUP"

source "${BUILD_ROOT}/bin/clean_box.sh"

highlight "Cleaning sources ..."

step "Cleaning .vagrant dir ..."
##rm -rf .vagrant/ || true
step "Cleaning packer_cache ..."
##rm -rf packer_cache/ || true
step "Cleaning packer output dir ..."
##rm -rf output-*/ || true
step "Drop build version ..."
##rm -f build_version || true
step "Drop build runtime ..."
##rm -f build_time || true
step "Deleting any box file ..."
##rm -f *.box || true
step "Cleanup old logs ..."
##rm -f *.log || true
step "Dropping build version ..."
##rm -f build_version || true
step "Dropping build runtime ..."
##rm -f build_time || true
step "Cleanup broken wget downloads ..."
##rm -f download || true
step "Cleanup checksum files ..."
##rm -f *.checksum || true
final "All done. You may now run './build.sh' to build a fresh box."
