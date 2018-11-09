#!/usr/bin/env bash

# Script to install the depenencies for LISA on an Ubuntu-like system.

# This is intended to be used for setting up containers and virtual machines to
# run LISA (e.g. for CI infrastructure or for Vagrant installation). However for
# the brave, it could be used to set up LISA directly on a real machine.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    echo Usage: "$0" [--install-android-sdk]
}

set -eu

install_android_sdk=n

for arg in "$@"; do
    if [ "$arg" == "--install-android-sdk" ]; then
        install_android_sdk=y
    else
        echo "Unrecognised argument: $arg"
        usage
        exit 1
    fi
done

#sudo dnf update -y

#apt-get -y remove ipython ipython-notebook

#apt-get -y install build-essential autoconf automake libtool pkg-config \
#    trace-cmd sshpass kernelshark nmap net-tools tree python-matplotlib \
#    python-numpy libfreetype6-dev libpng12-dev python-nose python-pip \
#    python-dev iputils-ping git wget expect

sudo dnf -y install kernelshark nmap trace-cmd nmap python-matplotlib expect freetype-devel libpng12-devel python2-devel

# Upgrade pip so we can use wheel packages instead of compiling stuff, this is
# much faster.
sudo pip install --upgrade pip

# Incantation to fix broken pip packages
sudo pip install --upgrade packaging appdirs

# Use IPython 5.x because 6.0+ only supports Python 3.3
sudo pip install --upgrade "ipython<6.0.0" Cython trappy bart-py devlib psutil wrapt jupyter

if [ "$install_android_sdk" == y ]; then
    sudo dnf -y install java-1.8.0-openjdk
    SDK_ZIP="sdk-tools-linux-4333796.zip"
    ANDROID_SDK_URL="https://dl.google.com/android/repository/$SDK_ZIP"
    mkdir -p "$SCRIPT_DIR"/tools
    if [ ! -e "$SCRIPT_DIR"/tools/android-sdk-linux ]; then
        echo "Downloading Android SDK [$ANDROID_SDK_URL]..."
	rm -rf $SDK_ZIP
        wget $ANDROID_SDK_URL
	rm -rf $SCRIPT_DIR/../android-sdk-linux
	unzip $SDK_ZIP -d $SCRIPT_DIR/../android-linux-sdk/
	rm -rf $SDK_ZIP
        expect -c "
            set timeout -1;
            spawn $SCRIPT_DIR/../android-sdk-linux/tools/android update sdk --no-ui
            expect {
                \"Do you accept the license\" { exp_send \"y\r\" ; exp_continue }
                eof
            }
        "
    fi
fi
