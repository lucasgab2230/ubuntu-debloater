#!/bin/bash
# install.sh
# Installation script for Ubuntu Debloater
# This script installs the debloater to your system for easy access.

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Exit if any command in a pipeline fails.
set -euo pipefail

# --- Configuration ---
INSTALL_DIR="/opt/ubuntu-debloater"
BIN_LINK="/usr/local/bin/ubuntu-debloater"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

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

# --- Installation ---
install_debloater() {
    log_info "Installing Ubuntu Debloater..."

    # Check if required files exist
    if [[ ! -f "${SCRIPT_DIR}/debloat.sh" ]]; then
        log_error "debloat.sh not found. Please run this script from the ubuntu-debloater directory."
    fi

    if [[ ! -d "${SCRIPT_DIR}/config" ]]; then
        log_error "config directory not found. Please run this script from the ubuntu-debloater directory."
    fi

    if [[ ! -d "${SCRIPT_DIR}/scripts" ]]; then
        log_error "scripts directory not found. Please run this script from the ubuntu-debloater directory."
    fi

    # Create installation directory
    log_info "Creating installation directory: ${INSTALL_DIR}"
    mkdir -p "${INSTALL_DIR}"

    # Copy files
    log_info "Copying files to ${INSTALL_DIR}..."
    cp "${SCRIPT_DIR}/debloat.sh" "${INSTALL_DIR}/"
    cp -r "${SCRIPT_DIR}/config" "${INSTALL_DIR}/"
    cp -r "${SCRIPT_DIR}/scripts" "${INSTALL_DIR}/"

    # Copy documentation if available
    if [[ -d "${SCRIPT_DIR}/docs" ]]; then
        cp -r "${SCRIPT_DIR}/docs" "${INSTALL_DIR}/"
    fi

    # Set permissions
    log_info "Setting permissions..."
    chmod 755 "${INSTALL_DIR}/debloat.sh"
    chmod 755 "${INSTALL_DIR}/scripts/"*.sh 2>/dev/null || true
    chmod -R 644 "${INSTALL_DIR}/config/"* 2>/dev/null || true
    chmod 755 "${INSTALL_DIR}/config"
    chmod 755 "${INSTALL_DIR}/scripts"

    # Create symbolic link
    log_info "Creating symbolic link: ${BIN_LINK}"
    ln -sf "${INSTALL_DIR}/debloat.sh" "${BIN_LINK}"

    log_success "Ubuntu Debloater installed successfully!"
    echo ""
    echo "You can now run the debloater using:"
    echo "  sudo ubuntu-debloater"
    echo ""
    echo "Installation directory: ${INSTALL_DIR}"
    echo "To uninstall, run: sudo rm -rf ${INSTALL_DIR} ${BIN_LINK}"
}

# --- Main ---
check_root
install_debloater
