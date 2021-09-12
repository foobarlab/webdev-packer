#!/bin/bash -ue
# vim: ts=4 sw=4 et

export BUILD_PARENT_BOX_CHECK=false

. config.sh quiet

require_commands vagrant

header "Finalizing box '$BUILD_BOX_NAME'"

# FIXME if finalized box exists, ask if delete and continue, or abort
step "Deleting previous finalized box if any ..."
rm -f $BUILD_OUTPUT_FILE

if [ -f "$BUILD_OUTPUT_FILE_INTERMEDIATE" ]; then
    step "Suspending any running instances ..."
    vagrant suspend || true
    step "Destroying current box ..."
    vagrant destroy -f || true
    step "Removing '$BUILD_BOX_NAME' ..."
    vagrant box remove -f "$BUILD_BOX_NAME" 2>/dev/null || true
    step "Adding '$BUILD_BOX_NAME' ..."
    vagrant box add --name "$BUILD_BOX_NAME" "$BUILD_OUTPUT_FILE_INTERMEDIATE"
    step "Powerup and provision '$BUILD_BOX_NAME' ..."
    vagrant up --provision --provision-with net_debug || { echo "Unable to startup '$BUILD_BOX_NAME'."; exit 1; }
    #vagrant provision --provision-with provision_ansible,remove_kernel,cleanup
    vagrant provision --provision-with provision_ansible,cleanup
    step "Exporting final box to '$BUILD_OUTPUT_FILE' ..."
    vagrant package --output "$BUILD_OUTPUT_FILE"
    result "Build finalized."
else
    error "There is no box file '$BUILD_OUTPUT_FILE_INTERMEDIATE' in the current directory."
    warn "You may need to run 'build.sh' first."
    exit 1
fi
