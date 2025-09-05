#!/usr/bin/env bash 
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")

export MAIN_SCRIPTS_DIR="/home/pi/drone/install/scripts"
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

run_step() {
    local step="$1"
    log "running $step..."
    bash "$step"
}

if [[ "${1:-}" == "--reinstall" ]]; then 
    log "reinstalling all packages..."

    if [ -d "$LOG_DIR" ]; then 
        rm -rf "$LOG_DIR"
    fi 
fi 

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