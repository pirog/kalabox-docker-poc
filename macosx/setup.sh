#!/bin/sh
#
# Kalabox Server Install Script.
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
echo "This script will help you get started running kalastack-docker"
echo ""
echo ""
echo "WHATCHA WHATCHA WHATCHA WANT?"
echo ""
echo "1. Install everything I need and set up a webserver for me."
echo "2. Install just the server dependencies."
echo "3. Forget this ever happened."
echo ""
read my_answer
if [ "$my_answer" == "3" ]; then
    echo "This never happened."
    key_exit 2
fi

# Initiate the actual uninstall, which requires admin privileges.
echo "The installation process requires administrative privileges"
echo "because some of the installed files cannot be removed by a"
echo "normal user. You may now be prompted for a password..."

# Just start the sudo party
sudo -p "Please enter %u's password:" echo "Let's get it started"

# Install VirtualBox
VBOX=$(which VBoxManage)
if [ -z "$VBOX" ]; then
    echo "Downloading VirtualBox..."
    cd /tmp
    curl -O http://files.kalamuna.com/virtualbox-macosx-4.3.6.dmg
    echo "Mounting VirtualBox..."
    if [ -d /Volumes/VirtualBox ]; then
        hdiutil detach /Volumes/VirtualBox -force
    fi
    hdiutil attach /tmp/virtualbox-macosx-4.3.6.dmg
    echo "Installing VirtualBox..."
    sudo installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /Volumes/Macintosh\ HD
    hdiutil detach /Volumes/VirtualBox -force
    echo "VirtualBox Installed!"
fi

# Install Boot2Docker
B2D=$(which boot2docker)
if [ -z "$B2D" ]; then
    echo "Downloading Boot2Docker..."
    cd /tmp
    curl -O http://files.kalamuna.com/boot2docker-v0.9.2-darwin-amd64
    echo "Installing Boot2Docker..."
    sudo mv /tmp/boot2docker-v0.9.2-darwin-amd64 /usr/local/bin/boot2docker
    sudo chmod +x /usr/local/bin/boot2docker
    echo "Boot2Docker Installed!"
fi

#!/usr/bin/env bash
if [ "$my_answer" == "1" ]; then
    echo "Spinning up the hypervisor..."
    B2D_DIR=$HOME/.boot2docker
    if [ ! -d "$B2D_DIR" ]; then
        mkdir -p "$B2D_DIR"
    fi
    if [ -a $B2D_DIR/boot2docker.iso ]; then
        rm $B2D_DIR/boot2docker.iso
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

    # Get all our images
    # Data only container
    curl -XPOST http://localhost:4243/images/create --data fromImage=busybox --data tag=latest
    curl -XPOST http://localhost:4243/images/create --data fromImage=pirog/kaladata-docker --data tag=latest
    # Ubuntu 12.04
    curl -XPOST http://localhost:4243/images/create --data fromImage=ubuntu --data tag=12.04
    # Reverse Proxy
    curl -XPOST http://localhost:4243/images/create --data fromImage=pirog/kalabox-proxy --data tag=latest
    # Kalastack Docker
    curl -XPOST http://localhost:4243/images/create --data fromImage=pirog/kalastack-docker --data tag=12.04

    # Set up the reverse proxy
    #json=$(/usr/bin/curl -XPOST -H "Content-Type: application/json" http://localhost:4243/containers/create -d '
    # {
    # "Hostname":"proxy.kala",
    # "User":"",
    # "Memory":0,
    # "MemorySwap":0,
    # "AttachStdin":false,
    # "AttachStdout":true,
    # "AttachStderr":true,
    # "PortSpecs":null,
    # "Privileged": false,
    # "Tty":false,
    # "OpenStdin":false,
    # "StdinOnce":false,
    # "Env":null,
    # "Dns":null,
    # "Image":"pirog/kalabox-proxy",
    # "Volumes":{},
    # "VolumesFrom":"",
    # "WorkingDir":""
    #}')
    #cid=$(echo $json | python -c 'import sys, json; print json.load(sys.stdin)[sys.argv[1]]' Id)
    #/usr/bin/curl -XPOST http://localhost:4243/containers/$cid/start
    #unset cid
    #unset json
fi

echo "Done."
key_exit 0;

