#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
MAIN_SCRIPTS_DIR="/home/pi/drone/install/scripts"
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

KERNEL_BRANCH="rpi-5.10.11-navio"
KERNEL_REPO="https://github.com/emlid/linux-rt-rpi.git"
KERNEL_FOLDER="linux-rt-rpi"

uncomment_line() {
  local key="$1" value="$2"
  local line="${key}=${value}"

  # Check if a commented version exists
  if grep -q -E "^#${line}$" "$BOOT_CONF"; then
    # Uncomment the line
    sed -i "s|^#${line}$|${line}|" "$BOOT_CONF"
    log "uncommented: ${line}"
  else
    log "not found or already uncommented: ${line}"
  fi
}

ensure_line(){
  local key="$1" value="$2"
  if ! grep -q -E "^${key}=${value}$" "$BOOT_CONF"; then
    echo "${key}=${value}" >> "$BOOT_CONF"
    log "added: ${key}=${value}"
  else
    log "already present: ${key}=${value}"
  fi
}

comment_line() {
  local key="$1" value="$2"
  local line="${key}=${value}"

  if grep -q -E "^${line}$" "$BOOT_CONF"; then
    # Comment it out (only if not already commented)
    sed -i "s|^${line}$|#${line}|" "$BOOT_CONF"
    log "commented: ${line}"
  else
    log "not found: ${line}"
  fi
}

require_root

log "clone the kernel source..."
if [ -d $USER_DIR/$KERNEL_FOLDER ]; then 
    rm -rf $USER_DIR/$KERNEL_FOLDER
fi 

cd $USER_DIR
git clone --depth=1 -b $KERNEL_BRANCH $KERNEL_REPO
cd $KERNEL_FOLDER 

log "preparing kernel configuration..."
KERNEL=kernel7
make ARCH=arm CROSS_COMPILE= -j$(nproc) bcm2709_defconfig

if [ ! -f "scripts/config" ]; then 
    sudo apt-get install -y -qq libncurses-dev 
    make menuconfig 
fi 

scripts/config --enable CONFIG_PREEMPT_RT
scripts/config --enable CONFIG_PREEMPT
scripts/config --disable CONFIG_DEBUG_PREEMPT

log "compiling the kernel..."
make -j$(nproc) zImage modules dtbs

log "installing kernels and modules..."
sudo make modules_install
sudo cp arch/arm/boot/zImage /boot/kernel7.img
sudo cp arch/arm/boot/dts/*.dtb /boot/
sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/

log "enabling navio2 device tree overlay..."
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$BOOT_CONF.bak-${STAMP}"
cp -a "$BOOT_CONF" "$BACKUP"

declare -A settings=(
    [enable_uart]=1
    [dtoverlay]=pi3-disable-bt
    [dtparam]=spi=on
    [dtparam]=i2c_arm=on
    [dtoverlay]=navio2
    [dtoverlay]=rcio
)

for key in "${!settings[@]}"; do
  value="${settings[$key]}"
  uncomment_line "$key" "$value"
  ensure_line "$key" "$value"
done

comment_line "dtoverlay" "vc4-kms-v3d"
