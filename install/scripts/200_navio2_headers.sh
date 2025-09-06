#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

log "checking to see if previous install ran successfully..."
if [ -f "$NAVIO2_HEADERS_INSTALL_FLAG" ]; then 
    log "Navio2 headers install was already run successfully"

    exit 0
fi 

log "install build dependencies..."
sudo apt update
sudo apt install -y git dkms build-essential raspberrypi-kernel-headers device-tree-compiler

log "checking for headers..."
if [ ! -d /lib/modules/$(uname -r)/build]; then 
    sudo apt-get full-upgrade -y 
fi 

if [ ! -d /lib/modules/$(uname -r)/build]; then 
    read -p "→ Headers for $(uname -r) do not exists." _
    exit 1
fi 

touch $NAVIO2_HEADERS_INSTALL_FLAG

read -p "→ Navio2 kernel headers installed. Press ENTER to reboot." _
sudo reboot