#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

log "checking to see if previous install ran successfully..."
if [ -f "$NAVIO2_KERNEL_INSTALL_FLAG" ]; then 
    log "Navio2 kernel install was already run successfully"

    exit 0
fi 

sudo bash $MAIN_SCRIPTS_DIR/900_navio2_kernel.sh

touch $NAVIO2_KERNEL_INSTALL_FLAG

read -p "→ Navio2 kernel and overlays installed. Press ENTER to reboot." _
sudo reboot