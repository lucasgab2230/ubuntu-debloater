#!/bin/bash

# 02-remove-packages.sh — Remove bloatware packages based on flavor

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

CONFIG_DIR="$SCRIPT_DIR/config"
FLAVOR_FILE="/tmp/ubuntu-flavor"

# Read detected flavor
if [[ -f "$FLAVOR_FILE" ]]; then
    FLAVOR=$(cat "$FLAVOR_FILE")
else
    log_warn "Flavor file not found. Defaulting to 'unknown'."
    FLAVOR="unknown"
fi

# Build list of package files to process
PACKAGE_FILES=("$CONFIG_DIR/common-packages.txt")

case "$FLAVOR" in
    ubuntu)
        PACKAGE_FILES+=("$CONFIG_DIR/ubuntu-packages.txt")
        ;;
    kubuntu)
        PACKAGE_FILES+=("$CONFIG_DIR/kubuntu-packages.txt")
        ;;
    xubuntu)
        PACKAGE_FILES+=("$CONFIG_DIR/xubuntu-packages.txt")
        ;;
    *)
        log_warn "No flavor-specific package list found for '$FLAVOR'."
        ;;
esac

# Include user-defined custom packages
if [[ -f "$CONFIG_DIR/custom-packages.txt" ]]; then
    PACKAGE_FILES+=("$CONFIG_DIR/custom-packages.txt")
fi

# Aggregate and deduplicate package list
PACKAGES_TO_REMOVE=()
for file in "${PACKAGE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        while IFS= read -r pkg; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            PACKAGES_TO_REMOVE+=("$pkg")
        done < "$file"
    else
        log_warn "Package list not found: $file"
    fi
done

# Remove duplicates
PACKAGES_TO_REMOVE=($(printf "%s\n" "${PACKAGES_TO_REMOVE[@]}" | sort -u))

# Remove packages
if [[ ${#PACKAGES_TO_REMOVE[@]} -eq 0 ]]; then
    log_info "No packages to remove."
else
    log_info "Removing ${#PACKAGES_TO_REMOVE[@]} packages..."
    apt-get update -qq
    apt-get purge -y "${PACKAGES_TO_REMOVE[@]}" && apt-get autoremove -y
    log_success "Package removal complete."
fi
