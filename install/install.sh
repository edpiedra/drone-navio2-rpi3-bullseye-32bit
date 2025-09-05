#!/usr/bin/env bash 
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")

export MAIN_SCRIPTS_DIR="/home/pi/drone/install/scripts"
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

run_step() {
    local step="$1"
    log "running $step..."
    sudo bash "$step"
}

require_root(){
  if [[ $EUID -ne 0 ]]; then
    echo "please run $SCRIPT_NAME with sudo." >&2
    exit 1
  fi
}

require_root()

if [ ! -d "$LOG_DIR" ]; then 
    mkdir "$LOG_DIR"
fi 

if [ -f "$NAVIO2_KERNEL_INSTALL_FLAG" ]; then 
    log "post-kernel install reboot tasks starting..."

    for step in "$MAIN_SCRIPTS_DIR"/2[0-9][0-9]_*.sh; do 
        run_step "$step"
    done 
elif [ -f "$FILESYSTEM_EXPANSION_FLAG" ]; then 
    log "post-filesystem expansion reboot tasks starting..."

    for step in "$MAIN_SCRIPTS_DIR"/1[0-9][0-9]_*.sh; do 
        run_step "$step"
    done 
else
    if [ -f "$LOG_FILE" ]; then 
        rm -f "$LOG_FILE"
    fi 

    for step in "$MAIN_SCRIPTS_DIR"/[0-9][0-9]_*.sh; do 
        run_step "$step"
    done 
fi