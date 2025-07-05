#!/bin/bash

# debloat.sh — Main entry point for Ubuntu Debloater
# Author: Lucas
# License: MIT

set -e

# === Constants ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
BACKUP_DIR="$SCRIPT_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_FILE="$LOG_DIR/debloat-$TIMESTAMP.log"
BACKUP_FILE="$BACKUP_DIR/installed-packages-$TIMESTAMP.txt"

# === Create necessary directories ===
mkdir -p "$LOG_DIR" "$BACKUP_DIR"

# === Load utilities ===
source "$SCRIPT_DIR/utils/logger.sh"
source "$SCRIPT_DIR/utils/helpers.sh"
source "$SCRIPT_DIR/utils/prompt.sh"

# === Log start ===
log_info "Starting Ubuntu Debloater at $TIMESTAMP"
log_info "Logging to $LOG_FILE"

# === Redirect all output to log file ===
exec > >(tee -a "$LOG_FILE") 2>&1

# === Run debloat steps ===
run_step() {
    local step_script="$1"
    if [[ -x "$step_script" ]]; then
        log_info "Running step: $(basename "$step_script")"
        "$step_script"
    else
        log_warn "Skipping non-executable step: $(basename "$step_script")"
    fi
}

# === Backup installed packages ===
log_info "Backing up list of installed packages..."
dpkg --get-selections > "$BACKUP_FILE"
log_info "Backup saved to $BACKUP_FILE"

# === Execute all scripts in order ===
for step in "$SCRIPT_DIR/scripts/"[0-9][0-9]-*.sh; do
    run_step "$step"
done

# === Done ===
log_success "Debloating complete! System cleaned and optimized."
