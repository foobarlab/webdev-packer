#!/bin/bash -ue
# vim: ts=4 sw=4 et

start=`date +%s`

export BUILD_PARENT_BOX_CHECK=true

vboxmanage=VBoxManage
command -v $vboxmanage >/dev/null 2>&1 || vboxmanage=vboxmanage   # try alternative

. config.sh quiet
. distfiles.sh


require_commands vagrant packer wget $vboxmanage

header "Building box '$BUILD_BOX_NAME'"

BUILD_PARENT_BOX_OVF="$HOME/.vagrant.d/boxes/$BUILD_PARENT_BOX_NAME/0/virtualbox/box.ovf"
BUILD_PARENT_BOX_CLOUD_PATHNAME=`echo "$BUILD_PARENT_BOX_CLOUD_NAME" | sed "s|/|-VAGRANTSLASH-|"`
BUILD_PARENT_BOX_CLOUD_OVF="$HOME/.vagrant.d/boxes/$BUILD_PARENT_BOX_CLOUD_PATHNAME/$BUILD_PARENT_BOX_CLOUD_VERSION/virtualbox/box.ovf"
BUILD_PARENT_BOX_CLOUD_VMDK="$HOME/.vagrant.d/boxes/$BUILD_PARENT_BOX_CLOUD_PATHNAME/$BUILD_PARENT_BOX_CLOUD_VERSION/virtualbox/box-disk001.vmdk"
BUILD_PARENT_BOX_CLOUD_VDI="$HOME/.vagrant.d/boxes/$BUILD_PARENT_BOX_CLOUD_PATHNAME/$BUILD_PARENT_BOX_CLOUD_VERSION/virtualbox/box-disk001.vdi"

if [ -f $BUILD_PARENT_BOX_OVF ]; then
    export BUILD_PARENT_OVF=$BUILD_PARENT_BOX_OVF
    warn "An existing local '$BUILD_PARENT_BOX_NAME' parent box was detected. Skipping download ..."
else
    export BUILD_PARENT_OVF=$BUILD_PARENT_BOX_CLOUD_OVF
    if [ -f $BUILD_PARENT_BOX_CLOUD_OVF ]; then
        echo
        warn "The '$BUILD_PARENT_BOX_CLOUD_NAME' parent box with version '$BUILD_PARENT_BOX_CLOUD_VERSION' has been previously downloaded."
        echo
        read -p "    Do you want to delete it and download again (y/N)? " choice
        case "$choice" in
          y|Y ) step "Deleting existing '$BUILD_PARENT_BOX_CLOUD_NAME' parent box ..."
                vagrant box remove $BUILD_PARENT_BOX_CLOUD_NAME --box-version $BUILD_PARENT_BOX_CLOUD_VERSION
          ;;
          * ) result "Will keep existing '$BUILD_PARENT_BOX_CLOUD_NAME' parent box.";;
        esac
    fi

    if [ -f $BUILD_PARENT_BOX_CLOUD_OVF ]; then
        step "'$BUILD_PARENT_BOX_CLOUD_NAME' box already present, no need for download."
    else
        step "Downloading '$BUILD_PARENT_BOX_CLOUD_NAME' box with version '$BUILD_PARENT_BOX_CLOUD_VERSION' ..."
        vagrant box add -f $BUILD_PARENT_BOX_CLOUD_NAME --box-version $BUILD_PARENT_BOX_CLOUD_VERSION --provider virtualbox
    fi
fi

if [ -d "keys" ]; then
    info "Ok, key dir exists."
else
    step "Creating key dir ..."
    mkdir -p keys
fi

if [ -f "keys/vagrant" ]; then
    info "Ok, private key exists."
else
    step "Downloading default private key ..."
    wget -c https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant -O keys/vagrant
    if [ $? -ne 0 ]; then
        error "Could not download the private key. Exit code from wget was $?."
        exit 1
    fi
fi

if [ -f "keys/vagrant.pub" ]; then
    info "Ok, public key exists."
else
    step "Downloading default public key ..."
    wget -c https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -O keys/vagrant.pub
    if [ $? -ne 0 ]; then
        error "Could not download the public key. Exit code from wget was $?."
        exit 1
    fi
fi

step "Create packages dir ..."
mkdir -p packages || true

todo "Resize parent box to $BUILD_BOX_DISKSIZE MB ..."

#info "Reading parent box OVF: '$BUILD_PARENT_BOX_CLOUD_OVF' ..."
#cat $BUILD_PARENT_BOX_CLOUD_OVF

todo "Show hdds"
$vboxmanage list hdds

todo "Remove previous resized vdi from Media Manager"
vbox_hdd_found=$( $vboxmanage list hdds | grep "$BUILD_PARENT_BOX_CLOUD_VDI" || echo )
#echo $vbox_hdd_found

if [[ -z "$vbox_hdd_found" || "$vbox_hdd_found" = "" ]]; then
    info "No HDDs named '"$BUILD_PARENT_BOX_CLOUD_VDI"' found."
else
    vbox_found_hdd_count=$( $vboxmanage list hdds | grep -o "^UUID" | wc -l )
    result "Found $vbox_found_hdd_count hdd(s)."
    todo "Searching for HDD UUID ..."
    # DEBUG:
    #$vboxmanage list hdds
    #$vboxmanage list hdds | grep -on "^UUID.*"
    #$vboxmanage list hdds | grep -on "^State:.*"
    #$vboxmanage list hdds | grep -on "^Location:.*"
    $vboxmanage list hdds | grep -o "^UUID.*"
    $vboxmanage list hdds | grep -o "^State:.*"
    $vboxmanage list hdds | grep -o "^Location:.*"
        
    declare -a vbox_hdd_uuids=( $( $vboxmanage list hdds | grep -o "^UUID:.*" | sed -e "s/^UUID: //g" ) )
    echo ${vbox_hdd_uuids[@]}
    
    vbox_hdd_locations=$( $vboxmanage list hdds | grep -o "^Location:.*" | sed -e "s/^Location:[[:space:]]*//g" | sed -e "s/\ /\\\ /g" ) #| sed -e "s/^/\"/g" | sed -e "s/$/\"/g"  )
    echo $vbox_hdd_locations
    # split string into array (preserving spaces in path)
    eval "declare -a vbox_hdd_locations2=($(echo "$vbox_hdd_locations" ))"
    echo ${vbox_hdd_locations2[@]}
    
    declare -a vbox_hdd_states=( $( $vboxmanage list hdds | grep -o "^State:.*" | sed -e "s/^State: //g" ) )
    echo ${vbox_hdd_states[@]}
    
    #for (( i=0; i<=${#vbox_hdd_uuids[@]}; i++ )); do
    for (( i=0; i<$vbox_found_hdd_count; i++ )); do
        echo "---"
        echo "UUID: ${vbox_hdd_uuids[$i]}"
        echo "Location: ${vbox_hdd_locations2[$i]}"
        echo "State: ${vbox_hdd_states[$i]}"
        
        if [[ "${vbox_hdd_locations2[$i]}" = "$BUILD_PARENT_BOX_CLOUD_VDI" ]]; then
            result "Found $BUILD_PARENT_BOX_CLOUD_VDI:"
            result "State: ${vbox_hdd_states[$i]}"
            result "UUID: ${vbox_hdd_uuids[$i]}"
            todo "Removing HDD from Media Manager ..."
            $vboxmanage closemedium disk ${vbox_hdd_uuids[$i]} --delete
        fi
    done
    
fi

todo "Remove previous resized vdi file"
rm -f "$BUILD_PARENT_BOX_CLOUD_VDI" || true

todo "Clone parent box hdd to vdi file"
$vboxmanage clonehd "$BUILD_PARENT_BOX_CLOUD_VMDK" "$BUILD_PARENT_BOX_CLOUD_VDI" --format VDI

todo "Resize vdi to $BUILD_BOX_DISKSIZE MB"
$vboxmanage modifyhd "$BUILD_PARENT_BOX_CLOUD_VDI" --resize $BUILD_BOX_DISKSIZE

todo "Attach vdi to parent box"
todo "Remove vmdk?"

#todo "Attach new disk (rewrite parent ovf?)"
#cat $BUILD_PARENT_BOX_CLOUD_OVF

#todo "Unattach old disk (rewrite parent ovf?)"
#cat $BUILD_PARENT_BOX_CLOUD_OVF

#todo "Remove VMDK"
#rm -f "$BUILD_PARENT_BOX_CLOUD_VMDK"
#
#todo "Clone VDI to VMDK"
##$vboxmanage clonemedium "$BUILD_PARENT_BOX_CLOUD_VDI" "$BUILD_PARENT_BOX_CLOUD_VMDK" --format vmdk
#$vboxmanage clonehd "$BUILD_PARENT_BOX_CLOUD_VDI" "$BUILD_PARENT_BOX_CLOUD_VMDK" --format vmdk
#
#todo "Remove VDI"
#rm -f "$BUILD_PARENT_BOX_CLOUD_VDI"
#
#todo "Cleanup Media Manager"
#
#todo "Resize disk (do in scripts)"
##resize2fs -p -F /dev/sda1

# see: https://github.com/sprotheroe/vagrant-disksize/blob/master/lib/vagrant/disksize/actions.rb

. config.sh

# DEBUG: stop here
exit 0

step "Invoking packer ..."
export PACKER_LOG_PATH="$PWD/packer.log"
export PACKER_LOG="1"
packer validate "$PWD/packer/virtualbox.json"
packer build -force -on-error=abort "$PWD/packer/virtualbox.json"

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
    step "Powerup and provision '$BUILD_BOX_NAME' (running only 'shell' scripts) ..."
    vagrant --provision up --provision-with net_debug,export_packages,cleanup_kernel,cleanup || { echo "Unable to startup '$BUILD_BOX_NAME'."; exit 1; }
    step "Halting '$BUILD_BOX_NAME' ..."
    vagrant halt
    # TODO vboxmanage modifymedium --compact <path to vdi>
    step "Exporting intermediate box to '$BUILD_OUTPUT_FILE_INTERMEDIATE' ..."
    vagrant package --output "$BUILD_OUTPUT_FILE_INTERMEDIATE"
    step "Removing temporary box file ..."
    rm -f  "$BUILD_OUTPUT_FILE_TEMP"
    result "Please run 'finalize.sh' to finish configuration and create the final box file."
else
    error "There is no box file '$BUILD_OUTPUT_FILE_TEMP' in the current directory."
    exit 1
fi

end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600));
minutes=$(( (runtime % 3600) / 60 ));
seconds=$(( (runtime % 3600) % 60 ));
echo "$hours hours $minutes minutes $seconds seconds" >> build_time
result "Build runtime was $hours hours $minutes minutes $seconds seconds."
