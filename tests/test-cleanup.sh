#!/bin/bash

# test-cleanup.sh — Test script for 04-cleanup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLEANUP_SCRIPT="$SCRIPT_DIR/scripts/04-cleanup.sh"

# Load logger
source "$SCRIPT_DIR/utils/logger.sh"

log_info "Running test: Cleanup script"

# Create mock files and directories to simulate cleanup targets
TEST_USER_DIR="/tmp/test-user"
mkdir -p "$TEST_USER_DIR/.cache/thumbnails"
mkdir -p "$TEST_USER_DIR/.local/share/Trash/files"
touch "$TEST_USER_DIR/.cache/thumbnails/test-thumb.png"
touch "$TEST_USER_DIR/.local/share/Trash/files/test-trash.txt"
touch /tmp/test-crash.crash
touch /var/log/test.log.1

# Simulate a home directory
export HOME="$TEST_USER_DIR"

# Run the cleanup script
if [[ -x "$CLEANUP_SCRIPT" ]]; then
    bash "$CLEANUP_SCRIPT"
else
    log_error "Cleanup script not found or not executable: $CLEANUP_SCRIPT"
    exit 1
fi

# Check if mock files were removed
if [[ ! -f "$TEST_USER_DIR/.cache/thumbnails/test-thumb.png" && ! -f "$TEST_USER_DIR/.local/share/Trash/files/test-trash.txt" ]]; then
    log_success "Thumbnail and Trash cleanup verified."
else
    log_error "Cleanup did not remove expected files."
    exit 1
fi

# Clean up test artifacts
rm -rf "$TEST_USER_DIR"
rm -f /tmp/test-crash.crash
rm -f /var/log/test.log.1

log_success "Test completed: Cleanup logic executed and verified."
