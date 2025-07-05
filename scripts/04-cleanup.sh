#!/bin/bash

# 04-cleanup.sh — Final cleanup of residual files and caches

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

log_info "Starting system cleanup..."

# Clean apt cache
log_info "Cleaning APT cache..."
apt-get clean
apt-get autoclean

# Remove orphaned packages
log_info "Removing orphaned packages..."
apt-get autoremove -y

# Remove old logs and crash reports
log_info "Removing old logs and crash reports..."
rm -rf /var/crash/*
rm -rf /var/log/*.gz /var/log/*.[0-9] /var/log/journal/*

# Clear thumbnail cache
log_info "Clearing user thumbnail cache..."
find /home -type d -name ".cache/thumbnails" -exec rm -rf {} +

# Clear Trash for all users
log_info "Emptying Trash for all users..."
find /home -type d -name ".local/share/Trash" -exec rm -rf {} +

log_success "System cleanup complete."
