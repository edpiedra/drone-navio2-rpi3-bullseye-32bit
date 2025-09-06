#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

log "checking to see if previous install ran successfully..."
if [ -f "$NAVIO2_RCIO_INSTALL_FLAG" ]; then 
    log "Navio2 rcio install was already run successfully"

    exit 0
fi 

sudo bash $MAIN_SCRIPTS_DIR/910_navio2_rcio.sh

touch $NAVIO2_RCIO_INSTALL_FLAG

read -p "→ Navio2 rcio installed. Press ENTER to reboot." _
sudo reboot