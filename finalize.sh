#!/bin/bash -e

echo "Executing $0 ..."

export BUILD_PARENT_BOX_CHECK=false

. config.sh

command -v vagrant >/dev/null 2>&1 || { echo "Command 'vagrant' required but it's not installed.  Aborting." >&2; exit 1; }

echo "Finalizing box ..."

# FIXME if finalized box exists, ask if delete and continue, or abort
echo "Deleting previous finalized box if any ..."
rm -f $BUILD_OUTPUT_FILE_FINAL

if [ -f "$BUILD_OUTPUT_FILE_INTERMEDIATE" ]; then
    echo "Suspending any running instances ..."
    vagrant suspend || true
    echo "Destroying current box ..."
    vagrant destroy -f || true
    echo "Removing '$BUILD_BOX_NAME' ..."
    vagrant box remove -f "$BUILD_BOX_NAME" 2>/dev/null || true
    echo "Adding '$BUILD_BOX_NAME' ..."
    vagrant box add --name "$BUILD_BOX_NAME" "$BUILD_OUTPUT_FILE_INTERMEDIATE"
    echo "Powerup and provision '$BUILD_BOX_NAME' ..."
    vagrant up --provision --provision-with net_debug || { echo "Unable to startup '$BUILD_BOX_NAME'."; exit 1; }
    vagrant provision --provision-with provision_ansible,cleanup
    echo "Exporting final box to '$BUILD_OUTPUT_FILE_FINAL' ..."
    vagrant package --output "$BUILD_OUTPUT_FILE_FINAL"
    echo "Build finalized."
else
    echo "There is no box file '$BUILD_OUTPUT_FILE_INTERMEDIATE' in the current directory. You may need to run 'build.sh' first."
    exit 1
fi
