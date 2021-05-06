#!/bin/bash -e

echo "Executing $0 ..."

export BUILD_PARENT_BOX_CHECK=false

. config.sh

command -v vagrant >/dev/null 2>&1 || { echo "Command 'vagrant' required but it's not installed.  Aborting." >&2; exit 1; }

echo "Testing Ansible provisioning ..."

if [ -f "$BUILD_OUTPUT_FILE_INTERMEDIATE" ]; then
	read -p "Do you want to initialize a new intermediate box (Y/n)? " choice
	case "$choice" in 
	  n|N ) echo "User skipped box initialization."
	  		;;
	    * ) echo "Suspending any running instances ..."
            vagrant suspend
            echo "Destroying current box ..."
            vagrant destroy -f || true
            echo "Removing '$BUILD_BOX_NAME' ..."
            vagrant box remove -f "$BUILD_BOX_NAME" 2>/dev/null || true
            echo "Adding '$BUILD_BOX_NAME' ..."
            vagrant box add --name "$BUILD_BOX_NAME" "$BUILD_OUTPUT_FILE_INTERMEDIATE"
	        ;;
	esac
    echo "Powerup and provision '$BUILD_BOX_NAME' (only 'ansible_local' is executed) ..."
    vagrant --provision up --provision-with ansible_local || { echo "Unable to startup '$BUILD_BOX_NAME'."; exit 1; }
    echo "Logging in ..."
    vagrant ssh
else
    echo "There is no box file '$BUILD_OUTPUT_FILE_INTERMEDIATE' in the current directory. You may need to run 'build.sh' first."
    exit 1
fi
