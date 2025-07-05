#!/bin/bash

# helpers.sh — General utility functions

# Load logger (optional)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

# Check if a package is installed
is_installed() {
    local pkg="$1"
    dpkg -l | grep -qw "$pkg"
}

# Check if a service exists
service_exists() {
    local svc="$1"
    systemctl list-unit-files | grep -q "^$svc"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Safely remove a package if installed
safe_remove_package() {
    local pkg="$1"
    if is_installed "$pkg"; then
        log_info "Removing package: $pkg"
        apt-get purge -y "$pkg"
    else
        log_warn "Package not installed: $pkg"
    fi
}

# Safely disable a service if it exists
safe_disable_service() {
    local svc="$1"
    if service_exists "$svc"; then
        log_info "Disabling service: $svc"
        systemctl disable --now "$svc"
    else
        log_warn "Service not found: $svc"
    fi
}
