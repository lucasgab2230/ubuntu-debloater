#!/bin/bash
# uninstall.sh
# Uninstallation script for Ubuntu Debloater
# This script removes the debloater from your system.

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Exit if any command in a pipeline fails.
set -euo pipefail

# --- Configuration ---
INSTALL_DIR="/opt/ubuntu-debloater"
BIN_LINK="/usr/local/bin/ubuntu-debloater"

# --- Logging Functions ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

log_success() {
    echo "[SUCCESS] $1"
}

# --- Check for root privileges ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)."
    fi
}

# --- Uninstallation ---
uninstall_debloater() {
    log_info "Uninstalling Ubuntu Debloater..."

    # Remove symbolic link
    if [[ -L "${BIN_LINK}" ]]; then
        log_info "Removing symbolic link: ${BIN_LINK}"
        rm -f "${BIN_LINK}"
    else
        log_info "Symbolic link not found: ${BIN_LINK}"
    fi

    # Remove installation directory
    if [[ -d "${INSTALL_DIR}" ]]; then
        log_info "Removing installation directory: ${INSTALL_DIR}"
        rm -rf "${INSTALL_DIR}"
    else
        log_info "Installation directory not found: ${INSTALL_DIR}"
    fi

    log_success "Ubuntu Debloater uninstalled successfully!"
}

# --- Main ---
check_root
uninstall_debloater
