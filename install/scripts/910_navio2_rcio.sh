#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
MAIN_SCRIPTS_DIR="/home/pi/drone/install/scripts"
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

RCIO_FOLDER="rcio-dkms"
RCIO_REPO="https://github.com/emlid/$RCIO_FOLDER.git"
RCIO_FIRMWARE="$USER_DIR/drone/firmware/rcio.fw"

log "cloning $RCIO_FOLDER..."
cd $USER_DIR 
if [ -d $USER_DIR/$RCIO_FOLDER ]; then 
    rm -rf $USER_DIR/$RCIO_FOLDER 
fi 
git clone $RCIO_REPO 
cd $RCIO_FOLDER 

log "building $RCIO_FOLDER..."
make 

log "installing via dkms..."
VER=$(grep '^PACKAGE_VERSION' dkms.conf | cut -d= -f2 | tr -d ' "')
sudo dkms remove rcio/$VER --all || true
sudo dkms install .

log "re-launch kernel module..."
sudo modprobe -r rcio_spi
sudo insmod rcio_core.ko
sudo insmod rcio_spi.ko

log "install the rcio overlay and firmware..."
sudo dtc -@ -I dts -O dtb -o /boot/overlays/rcio.dtbo rcio-overlay.dts
sudo install -m 0644 $RCIO_FIRMWARE /lib/firmware/rcio.fw