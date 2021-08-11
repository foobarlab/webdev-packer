#!/bin/bash -ue
# vim: ts=4 sw=4 et

command -v vagrant >/dev/null 2>&1 || { echo "Command 'vagrant' required but it's not installed.  Aborting." >&2; exit 1; }

. config.sh

echo "==> Starting '$BUILD_BOX_NAME' box ..."

echo "Powerup '$BUILD_BOX_NAME' ..."
vagrant up --no-provision || { echo "Unable to startup '$BUILD_BOX_NAME'."; exit 1; }
echo "Establishing SSH connection to '$BUILD_BOX_NAME' ..."
vagrant ssh
