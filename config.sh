#!/bin/bash
# vim: ts=4 sw=4 et

. ./lib/functions.sh
require_commands git nproc
set -a

. version.sh

# ----------------------------!  edit settings below  !----------------------------

export BUILD_BOX_NAME="webdev"
export BUILD_BOX_USERNAME="foobarlab"

export BUILD_BOX_PROVIDER="virtualbox"

export BUILD_BOX_SOURCES="https://github.com/foobarlab/webdev-packer"

export BUILD_PARENT_BOX_USERNAME="foobarlab"
export BUILD_PARENT_BOX_NAME="funtoo-base"
export BUILD_PARENT_BOX_CLOUD_NAME="$BUILD_PARENT_BOX_USERNAME/$BUILD_PARENT_BOX_NAME"

export BUILD_GUEST_TYPE="Gentoo_64"

# default memory/cpus used for final created box:
export BUILD_BOX_CPUS="2"
export BUILD_BOX_MEMORY="2048"
export BUILD_BOX_DISKSIZE="50000" # MB

# add a custom overlay?
export BUILD_CUSTOM_OVERLAY=false
export BUILD_CUSTOM_OVERLAY_NAME="myreponame"
export BUILD_CUSTOM_OVERLAY_URL="https://github.com/username/myreponame-overlay.git"
export BUILD_CUSTOM_OVERLAY_BRANCH="main"

# TODO make finalize step optional, like:
#export BUILD_AUTO_FINALIZE=false  # if 'true' automatically run finalize.sh script

export BUILD_KERNEL=false                 # build a new kernel?
export BUILD_HEADLESS=true                # if true, gui will be uninstalled, otherwise gui will be shown
# TODO flag for xorg (BUILD_WINDOW_SYSTEM)?

export BUILD_MYSQL_ROOT_PASSWORD=changeme # set the root password for MySQL/MariaDB

export BUILD_KEEP_MAX_CLOUD_BOXES=1       # set the maximum number of boxes to keep in Vagrant Cloud

# ----------------------------! do not edit below this line !----------------------------

# detect number of system cpus available (select half of cpus for best performance)
export BUILD_CPUS=$((`nproc --all` / 2))
let "jobs = $BUILD_CPUS + 1"       # calculate number of jobs (threads + 1)
export BUILD_MAKEOPTS="-j${jobs}"

# determine ram available (select min and max)
BUILD_MEMORY_MIN=4096 # we want at least 4G ram for our build
# calculate max memory (set to 1/2 of available memory)
BUILD_MEMORY_MAX=$(((`grep MemTotal /proc/meminfo | awk '{print $2}'` / 1024 / 1024 / 2 + 1 ) * 1024))
let "memory = $BUILD_CPUS * 1024"   # calculate 1G ram for each cpu
BUILD_MEMORY="${memory}"
BUILD_MEMORY=$(($BUILD_MEMORY < $BUILD_MEMORY_MIN ? $BUILD_MEMORY_MIN : $BUILD_MEMORY)) # lower limit (min)
BUILD_MEMORY=$(($BUILD_MEMORY > $BUILD_MEMORY_MAX ? $BUILD_MEMORY_MAX : $BUILD_MEMORY)) # upper limit (max)
export BUILD_MEMORY

export BUILD_BOX_RELEASE_NOTES="Web development environment based on Funtoo Linux. See README in sources for details."     # edit this to reflect actual setup

export BUILD_TIMESTAMP="$(date --iso-8601=seconds)"

BUILD_BOX_DESCRIPTION="$BUILD_BOX_NAME version $BUILD_BOX_VERSION"
if [ -z ${BUILD_TAG+x} ]; then
    # without build tag
    BUILD_BOX_DESCRIPTION="$BUILD_BOX_DESCRIPTION"
else
    # with env var BUILD_TAG set
    # NOTE: for Jenkins builds we got some additional information: BUILD_NUMBER, BUILD_ID, BUILD_DISPLAY_NAME, BUILD_TAG, BUILD_URL
    BUILD_BOX_DESCRIPTION="$BUILD_BOX_DESCRIPTION ($BUILD_TAG)"
fi

export BUILD_GIT_COMMIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
export BUILD_GIT_COMMIT_ID=`git rev-parse HEAD`
export BUILD_GIT_COMMIT_ID_SHORT=`git rev-parse --short HEAD`
export BUILD_GIT_COMMIT_ID_HREF="${BUILD_BOX_SOURCES}/tree/${BUILD_GIT_COMMIT_ID}"

export BUILD_BOX_DESCRIPTION="$BUILD_BOX_RELEASE_NOTES<br><br>$BUILD_BOX_DESCRIPTION<br>created @$BUILD_TIMESTAMP<br><br>Source code: $BUILD_BOX_SOURCES<br>This build is based on branch $BUILD_GIT_COMMIT_BRANCH (commit id <a href=\\\"$BUILD_GIT_COMMIT_ID_HREF\\\">$BUILD_GIT_COMMIT_ID_SHORT</a>)"

export BUILD_OUTPUT_FILE_TEMP="$BUILD_BOX_NAME-$BUILD_BOX_VERSION.tmp.box"
export BUILD_OUTPUT_FILE_INTERMEDIATE="$BUILD_BOX_NAME-$BUILD_BOX_VERSION.raw.box"
export BUILD_OUTPUT_FILE="$BUILD_BOX_NAME-$BUILD_BOX_VERSION.box"

# get the latest parent version from Vagrant Cloud API call:
. parent_version.sh

if [ $# -eq 0 ]; then
    title "BUILD SETTINGS"
    if [ "$ANSI" = "true" ]; then
        env | grep BUILD_ | sort | awk -F"=" '{ printf("'${white}${bold}'%.40s '${default}'%s\n",  $1 "'${dark_grey}'........................................'${default}'" , $2) }'
    else
      env | grep BUILD_ | sort | awk -F"=" '{ printf("%.40s %s\n",  $1 "........................................" , $2) }'
    fi
    title_divider
fi
