#!/bin/sh
#
# Kalabox Install Script.
#
# Copyright (C) 2014 Kalamuna LLC
#
# This file will install the underlying dependencies required to run
# kalastack-docker.
#

# Override any funny stuff from the user.
export PATH="/bin:/usr/bin:/sbin:/usr/sbin:$PATH"
SCRIPT_DIR=$(pwd)

## @param [Integer] $1 exit code.
function key_exit() {
    echo "Press enter to exit."
    read
    exit $1
}

##
# Display some important knowledge first
#
echo ""
echo "Welcome to the kalastack-docker server install script."
echo ""
echo "This script will help you get started running Kalabox"
echo ""
echo ""
echo "WHATCHA WHATCHA WHATCHA WANT?"
echo ""
echo "1. Install all the things."
echo "2. Forget this ever happened."
echo ""
read my_answer
if [ "$my_answer" == "2" ]; then
    echo "This never happened."
    key_exit 2
fi

# Setup the VM and get docker ready
if [ "$my_answer" == "1" ]; then
    # Initiate the actual uninstall, which requires admin privileges.
    echo "The installation process requires administrative privileges"
    echo "because some of the installed files cannot be removed by a"
    echo "normal user. You may now be prompted for a password..."

    # Just start the sudo party
    echo "Let's get it started!"

    # Install Boot2Docker
    B2D_INSTALLED=$(system_profiler SPApplicationsDataType | grep boot2docker)
    if [ -z "$B2D_INSTALLED" ]; then
        echo "Downloading Boot2Docker..."
        cd /tmp
        curl -O http://files.kalamuna.com/boot2docker-macosx-1.1.1.pkg
        MACVOL=$(diskutil info / | sed -n '/Volume Name:/ s/.*Volume Name: *//p')
        echo "Your Mac volume is called $MACVOL"
        /usr/bin/sudo -p "Please enter %u's password:" installer -pkg /tmp/boot2docker-macosx-1.1.1.pkg -target /Volumes/"$MACVOL"
        echo "Boot2Docker Installed!"
    fi

    echo "Spinning up the hypervisor..."
    B2D_DIR=$HOME/.boot2docker
    if [ ! -d "$B2D_DIR" ]; then
        mkdir -p "$B2D_DIR"
    fi
    # @todo eventually we want to do something less instrusive like this
    # export BOOT2DOCKER_PROFILE=$(pwd)/boot2docker.profile
    # unset BOOT2DOCKER_PROFILE
    # For now we need to overwrite the default settings to ensure pegging
    cp -f $SCRIPT_DIR/boot2docker.profile $HOME/.boot2docker
    mv -f $HOME/.boot2docker/boot2docker.profile $HOME/.boot2docker/profile

    # Build the Docker VM
    cd $HOME
    boot2docker init
    boot2docker up
    # Not sure if we need to set this correctly
    B2D_IP=$(boot2docker ip 2>/dev/null)
    export DOCKER_HOST=tcp://$B2D_IP:2375

    # Spin up all the containers we need to get starter
    # @todo: We should remove this for now
    docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock -t pirog/kalabox-proxy
    docker run --name=test_data pirog/kaladata-docker
    docker run -d -t -e VIRTUAL_HOST=test.kala -e VIRTUAL_PORT=80 -p :22 -p :80 -p :3306 --volumes-from="test_data" --name="test.kala" --hostname="test.kala" pirog/kalastack-docker:latest

    # Add a hosts entry
    # 1.3.3.7 test.kala
    # usr/bin/sudo -p "Please enter %u's password:" echo "$B2D_IP test.kala" >> /etc/hosts
fi

echo "Done."
key_exit 0;

