#!/bin/bash -ue
# vim: ts=4 sw=4 et

start=`date +%s`

export BUILD_PARENT_BOX_CHECK=true

. config.sh quiet
. distfiles.sh


require_commands vagrant packer wget

header "Building box '$BUILD_BOX_NAME'"

BUILD_PARENT_BOX_OVF="$HOME/.vagrant.d/boxes/$BUILD_PARENT_BOX_NAME/0/virtualbox/box.ovf"
BUILD_PARENT_BOX_VAGRANTCLOUD_PATHNAME=`echo "$BUILD_PARENT_BOX_VAGRANTCLOUD_NAME" | sed "s|/|-VAGRANTSLASH-|"`
BUILD_PARENT_BOX_VAGRANTCLOUD_OVF="$HOME/.vagrant.d/boxes/$BUILD_PARENT_BOX_VAGRANTCLOUD_PATHNAME/$BUILD_PARENT_BOX_VAGRANTCLOUD_VERSION/virtualbox/box.ovf"

if [ -f $BUILD_PARENT_BOX_OVF ]; then
    export BUILD_PARENT_OVF=$BUILD_PARENT_BOX_OVF
    echo "An existing local '$BUILD_PARENT_BOX_NAME' box was detected. Skipping download ..."
else
    export BUILD_PARENT_OVF=$BUILD_PARENT_BOX_VAGRANTCLOUD_OVF
    if [ -f $BUILD_PARENT_BOX_VAGRANTCLOUD_OVF ]; then
        echo "An existing '$BUILD_PARENT_BOX_VAGRANTCLOUD_NAME' box download with version '$BUILD_PARENT_BOX_VAGRANTCLOUD_VERSION' was detected."
        read -p "Do you want to delete it and download again (y/N)? " choice
        case "$choice" in
          y|Y ) echo "Deleting existing '$BUILD_PARENT_BOX_VAGRANTCLOUD_NAME' box ..."
                vagrant box remove $BUILD_PARENT_BOX_VAGRANTCLOUD_NAME --box-version $BUILD_PARENT_BOX_VAGRANTCLOUD_VERSION
          ;;
          * ) echo "Will keep existing '$BUILD_PARENT_BOX_VAGRANTCLOUD_NAME' box.";;
        esac
    fi

    if [ -f $BUILD_PARENT_BOX_VAGRANTCLOUD_OVF ]; then
        echo "'$BUILD_PARENT_BOX_VAGRANTCLOUD_NAME' box already present, no need for download."
    else
        echo "Downloading '$BUILD_PARENT_BOX_VAGRANTCLOUD_NAME' box with version '$BUILD_PARENT_BOX_VAGRANTCLOUD_VERSION' ..."
        vagrant box add -f $BUILD_PARENT_BOX_VAGRANTCLOUD_NAME --box-version $BUILD_PARENT_BOX_VAGRANTCLOUD_VERSION --provider virtualbox
    fi
fi

if [ -d "keys" ]; then
    echo "Ok, key dir exists."
else
    echo "Creating key dir ..."
    mkdir -p keys
fi

if [ -f "keys/vagrant" ]; then
    echo "Ok, private key exists."
else
    echo "Downloading default private key ..."
    wget https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant -O keys/vagrant
    if [ $? -ne 0 ]; then
        echo "Could not download the private key. Exit code from wget was $?."
        exit 1
    fi
fi

if [ -f "keys/vagrant.pub" ]; then
    echo "Ok, public key exists."
else
    echo "Downloading default public key ..."
    wget https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -O keys/vagrant.pub
    if [ $? -ne 0 ]; then
        echo "Could not download the public key. Exit code from wget was $?."
        exit 1
    fi
fi

# TODO include version info from file (copy to scripts?)

. config.sh

mkdir -p packages || true
export PACKER_LOG_PATH="$PWD/packer.log"
export PACKER_LOG="1"
packer validate virtualbox.json
packer build -force -on-error=abort virtualbox.json

title "OPTIMIZING BOX SIZE"

if [ -f "$BUILD_OUTPUT_FILE_TEMP" ]; then
    step "Suspending any running instances ..."
    vagrant suspend
    step "Destroying current box ..."
    vagrant destroy -f || true
    step "Removing '$BUILD_BOX_NAME' ..."
    vagrant box remove -f "$BUILD_BOX_NAME" 2>/dev/null || true
    step "Adding '$BUILD_BOX_NAME' ..."
    vagrant box add --name "$BUILD_BOX_NAME" "$BUILD_OUTPUT_FILE_TEMP"
    echo "Powerup and provision '$BUILD_BOX_NAME' (running only 'shell' scripts) ..."
    vagrant --provision up --provision-with net_debug,export_packages,cleanup_kernel,cleanup || { echo "Unable to startup '$BUILD_BOX_NAME'."; exit 1; }
    echo "Exporting intermediate box to '$BUILD_OUTPUT_FILE_INTERMEDIATE' ..."
    vagrant package --output "$BUILD_OUTPUT_FILE_INTERMEDIATE"
    echo "Removing temporary box file ..."
    rm -f  "$BUILD_OUTPUT_FILE_TEMP"
    # TODO rename packer.log for backup
    echo "Please run 'finalize.sh' to finish configuration and create the final box file."
else
    echo "There is no box file '$BUILD_OUTPUT_FILE_TEMP' in the current directory."
    exit 1
fi
