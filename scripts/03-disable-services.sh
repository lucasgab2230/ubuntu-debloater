#!/bin/bash

# 03-disable-services.sh — Disable unnecessary services based on flavor

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

SERVICES_DIR="$SCRIPT_DIR/services"
FLAVOR_FILE="/tmp/ubuntu-flavor"

# Read detected flavor
if [[ -f "$FLAVOR_FILE" ]]; then
    FLAVOR=$(cat "$FLAVOR_FILE")
else
    log_warn "Flavor file not found. Defaulting to 'unknown'."
    FLAVOR="unknown"
fi

# Build list of service files to process
SERVICE_FILES=("$SERVICES_DIR/common-services.txt")

case "$FLAVOR" in
    ubuntu)
        SERVICE_FILES+=("$SERVICES_DIR/ubuntu-services.txt")
        ;;
    kubuntu)
        SERVICE_FILES+=("$SERVICES_DIR/kubuntu-services.txt")
        ;;
    xubuntu)
        SERVICE_FILES+=("$SERVICES_DIR/xubuntu-services.txt")
        ;;
    *)
        log_warn "No flavor-specific service list found for '$FLAVOR'."
        ;;
esac

# Aggregate and deduplicate service list
SERVICES_TO_DISABLE=()
for file in "${SERVICE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        while IFS= read -r svc; do
            [[ "$svc" =~ ^#.*$ || -z "$svc" ]] && continue
            SERVICES_TO_DISABLE+=("$svc")
        done < "$file"
    else
        log_warn "Service list not found: $file"
    fi
done

# Remove duplicates
SERVICES_TO_DISABLE=($(printf "%s\n" "${SERVICES_TO_DISABLE[@]}" | sort -u))

# Disable services
if [[ ${#SERVICES_TO_DISABLE[@]} -eq 0 ]]; then
    log_info "No services to disable."
else
    log_info "Disabling ${#SERVICES_TO_DISABLE[@]} services..."
    for svc in "${SERVICES_TO_DISABLE[@]}"; do
        if systemctl list-unit-files | grep -q "^$svc"; then
            systemctl disable --now "$svc" && log_info "Disabled: $svc"
        else
            log_warn "Service not found: $svc"
        fi
    done
    log_success "Service disabling complete."
fi
