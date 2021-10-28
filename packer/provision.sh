#!/bin/bash -ue
# vim: ts=2 sw=2 et

if [ -z ${BUILD_RUN:-} ]; then
  echo "This script can not be run directly! Aborting."
  exit 1
fi

if [ -z ${scripts:-} ]; then
  scripts=.
fi

chmod +x ${scripts}/scripts/*.sh

for script in \
  10-prepare \
  20-kernel \
  25-headless \
  30-system-update \
  40-languages \
  50-services \
  60-database \
  70-misc \
  80-utils \
  82-webtools \
  90-postprocess \
  99-cleanup
do
  echo "==============================================================================="
  echo " >>> Running $script.sh"
  echo "==============================================================================="
  "$scripts/scripts/$script.sh"
  printf "\n\n"
done

echo "All done."
