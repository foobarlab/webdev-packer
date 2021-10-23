#!/bin/bash -ue
# vim: ts=4 sw=4 et

export BUILD_PARENT_BOX_CHECK=false

. config.sh quiet

require_commands vagrant

title "TESTING ANSIBLE PROVISIONER"

if [ -f "$BUILD_OUTPUT_FILE_INTERMEDIATE" ]; then
    echo
    read -p "    Do you want to initialize a new intermediate box (Y/n)? " choice
    echo
    case "$choice" in
      n|N ) step "User skipped box initialization."
            ;;
        * ) step "Suspending any running instances ..."
            vagrant suspend
            step "Destroying current box ..."
            vagrant destroy -f || true
            step "Removing '$BUILD_BOX_NAME' ..."
            vagrant box remove -f "$BUILD_BOX_NAME" 2>/dev/null || true
            step "Adding '$BUILD_BOX_NAME' ..."
            vagrant box add --name "$BUILD_BOX_NAME" "$BUILD_OUTPUT_FILE_INTERMEDIATE"
            ;;
    esac
    highlight "Powerup and provision '$BUILD_BOX_NAME' (only 'ansible_local' is executed) ..."
    vagrant --provision up --provision-with ansible_local || { echo "Unable to startup '$BUILD_BOX_NAME'."; exit 1; }
    step "Logging in ..."
    vagrant ssh
else
    error "There is no box file '$BUILD_OUTPUT_FILE_INTERMEDIATE' in the current directory."
    info "You may need to run 'build.sh' first."
    exit 1
fi
