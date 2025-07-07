#!/bin/bash
# scripts/functions.sh
# Common functions for the Ubuntu Debloater script (debloat.sh).
# This file is sourced by debloat.sh to provide reusable utilities.

# Function to log informational messages
log_info() {
    echo "[INFO] $1"
}

# Function to log error messages and exit
log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Function to display a formatted message to the user
display_message() {
    echo ""
    echo "----------------------------------------------------"
    echo "$1"
    echo "----------------------------------------------------"
    echo ""
}

# Function to confirm an action with the user
# Returns 0 for 'yes', 1 for 'no'
confirm_action() {
    read -rp "$1 (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true # Returns 0 (success)
            ;;
        *)
            false # Returns 1 (failure)
            ;;
    esac
}

# Function to detect the Linux distribution based on /etc/os-release
# Returns the detected distribution name (e.g., "Ubuntu", "Kubuntu", "Linux Mint")
# Exits with an error if detection fails or distribution is unsupported.
detect_distro() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_LIKE="$ID_LIKE"
        # DISTRO_VERSION_ID="$VERSION_ID" # Not strictly needed for this logic, but useful for more granular checks

        case "$DISTRO_ID" in
            ubuntu)
                # For standard Ubuntu, we return "Ubuntu".
                # More advanced detection might check for desktop environment (e.g., GNOME)
                echo "Ubuntu"
                ;;
            kubuntu)
                echo "Kubuntu"
                ;;
            xubuntu)
                echo "Xubuntu"
                ;;
            lubuntu)
                echo "Lubuntu"
                ;;
            linuxmint)
                echo "Linux Mint"
                ;;
            *)
                # Fallback for Ubuntu-like systems that might not have a direct ID match
                if [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
                    echo "Ubuntu"
                else
                    log_error "Unsupported distribution: $DISTRO_ID. This debloater supports Ubuntu and its derivatives."
                fi
                ;;
        esac
    else
        log_error "Could not detect distribution. /etc/os-release not found."
    fi
}

# Function to check if a command exists in the system's PATH
# Returns 0 if the command exists, 1 otherwise.
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
