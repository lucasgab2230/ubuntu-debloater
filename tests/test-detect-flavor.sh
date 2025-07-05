#!/bin/bash

# test-detect-flavor.sh — Test script for 01-detect-flavor.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/scripts/01-detect-flavor.sh"
FLAVOR_FILE="/tmp/ubuntu-flavor"

# Load logger
source "$SCRIPT_DIR/utils/logger.sh"

log_info "Running test: Detect Ubuntu flavor"

# Run the detection script
if [[ -x "$DETECT_SCRIPT" ]]; then
    bash "$DETECT_SCRIPT"
else
    log_error "Detection script not found or not executable: $DETECT_SCRIPT"
    exit 1
fi

# Check the result
if [[ -f "$FLAVOR_FILE" ]]; then
    FLAVOR=$(cat "$FLAVOR_FILE")
    case "$FLAVOR" in
        ubuntu|kubuntu|xubuntu)
            log_success "Detected flavor: $FLAVOR"
            ;;
        unknown)
            log_warn "Flavor detection returned 'unknown'."
            ;;
        *)
            log_error "Unexpected flavor value: $FLAVOR"
            exit 1
            ;;
    esac
else
    log_error "Flavor file not created: $FLAVOR_FILE"
    exit 1
fi

log_info "Test completed."
