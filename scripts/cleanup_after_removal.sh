#!/bin/bash
# scripts/cleanup_after_removal.sh
# Script to perform post-removal cleanup operations for the Ubuntu Debloater.
# This script is designed to be called by debloat.sh after package removal.

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# --- Common functions (for logging, assuming debloat.sh sources functions.sh) ---
# In a real setup, debloat.sh would have already sourced functions.sh.
# For this standalone script, we'll include minimal logging functions or assume
# they are available if this script is called by debloat.sh.
# For simplicity, we'll just use echo for output here.

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
    # This script is called by debloat.sh, so we might not want to exit here
    # if debloat.sh handles errors, but for a standalone script, exiting is fine.
    # For now, we'll let debloat.sh handle the overall exit status.
}

# --- Main Cleanup Logic ---

log_info "Starting post-removal cleanup operations..."

# Remove unused dependencies and configuration files
display_message "Running 'sudo apt autoremove --purge' to remove unused dependencies..."
if ! sudo apt-get autoremove --purge --assume-yes; then
    log_error "Autoremove failed. Please check for errors in the output above."
else
    log_info "Autoremove completed successfully."
fi

# Clear the local package cache
display_message "Running 'sudo apt autoclean' to clear local package cache..."
if ! sudo apt-get autoclean --assume-yes; then
    log_error "Autoclean failed. Please check for errors in the output above."
else
    log_info "Autoclean completed successfully."
fi

log_info "All cleanup operations finished."
