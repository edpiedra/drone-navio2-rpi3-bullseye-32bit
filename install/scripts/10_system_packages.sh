#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

log "updating system packages..."
sudo apt-get update && sudo apt-get -y -qq dist-upgrade

if [ ! -f "$FILESYSTEM_EXPANSION_FLAG" ]; then
    log "expanding filesystem..."
    sudo raspi-config --expand-rootfs
    touch "$FILESYSTEM_EXPANSION_FLAG"

    read -p "→ Expanded filesystem. Press ENTER to reboot." _
    sudo reboot
fi 