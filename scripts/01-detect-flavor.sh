#!/bin/bash

# 01-detect-flavor.sh — Detect the current Ubuntu flavor

# Load logger utility
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

FLAVOR_FILE="/tmp/ubuntu-flavor"

# Detect flavor based on installed desktop packages
detect_flavor() {
    if dpkg -l | grep -q kubuntu-desktop; then
        echo "kubuntu"
    elif dpkg -l | grep -q xubuntu-desktop; then
        echo "xubuntu"
    elif dpkg -l | grep -q ubuntu-desktop; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

FLAVOR=$(detect_flavor)
echo "$FLAVOR" > "$FLAVOR_FILE"

if [[ "$FLAVOR" == "unknown" ]]; then
    log_warn "Could not detect Ubuntu flavor. Defaulting to common package list only."
else
    log_success "Detected Ubuntu flavor: $FLAVOR"
fi
