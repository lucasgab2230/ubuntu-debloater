#!/bin/bash

# 00-check-root.sh — Ensure the script is run as root

# Load logger utility
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

# Check for root privileges
if [[ "$EUID" -ne 0 ]]; then
    log_error "This script must be run as root. Please use sudo."
    exit 1
else
    log_success "Root privileges confirmed."
fi
