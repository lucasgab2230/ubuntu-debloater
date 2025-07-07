#!/bin/bash
# debloat.sh
# Main script to remove bloatware from Ubuntu and its derivatives.

# --- Configuration and Setup ---

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Exit if any command in a pipeline fails.
set -euo pipefail

# Define base directory (where debloat.sh is located)
BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="${BASE_DIR}/config"
SCRIPTS_DIR="${BASE_DIR}/scripts"

# --- Common functions (normally in functions.sh, included here for single-file completeness) ---
# In a real setup, you would source this file: source "${SCRIPTS_DIR}/functions.sh"

# Function to log informational messages
log_info() {
    echo "[INFO] $1"
}

# Function to log error messages
log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Function to display a message to the user
display_message() {
    echo ""
    echo "----------------------------------------------------"
    echo "$1"
    echo "----------------------------------------------------"
    echo ""
}

# Function to confirm an action with the user
confirm_action() {
    read -rp "$1 (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Function to detect the Linux distribution
detect_distro() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_LIKE="$ID_LIKE"
        DISTRO_VERSION_ID="$VERSION_ID"

        case "$DISTRO_ID" in
            ubuntu)
                # Differentiate between Ubuntu and its flavors by checking desktop environment or other indicators if needed
                # For simplicity, we'll just return "Ubuntu" for now.
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
                if [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
                    echo "Ubuntu" # Treat Ubuntu-like as Ubuntu
                else
                    log_error "Unsupported distribution: $DISTRO_ID. This debloater supports Ubuntu and its derivatives."
                fi
                ;;
        esac
    else
        log_error "Could not detect distribution. /etc/os-release not found."
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- End of common functions ---


# Ensure apt is available
if ! command_exists apt; then
    log_error "APT package manager not found. This script requires APT."
fi

# --- Main Script Logic ---

log_info "Starting Ubuntu Debloater..."

# Detect distribution
DISTRO=$(detect_distro)
log_info "Detected distribution: $DISTRO"

PACKAGE_LIST_FILE=""

case "$DISTRO" in
    "Ubuntu")
        PACKAGE_LIST_FILE="${CONFIG_DIR}/ubuntu_bloat.list"
        ;;
    "Kubuntu")
        PACKAGE_LIST_FILE="${CONFIG_DIR}/kubuntu_bloat.list"
        ;;
    "Xubuntu")
        PACKAGE_LIST_FILE="${CONFIG_DIR}/xubuntu_bloat.list"
        ;;
    "Lubuntu")
        PACKAGE_LIST_FILE="${CONFIG_DIR}/lubuntu_bloat.list"
        ;;
    "Linux Mint")
        PACKAGE_LIST_FILE="${CONFIG_DIR}/mint_bloat.list"
        ;;
    *)
        log_error "No specific package list found for $DISTRO. Exiting."
        ;;
esac

# Check if the package list file exists
if [ ! -f "$PACKAGE_LIST_FILE" ]; then
    log_error "Package list file not found: $PACKAGE_LIST_FILE. Please ensure it exists."
fi

# Read packages into an array, filtering out empty lines and comments
mapfile -t PACKAGES_TO_REMOVE < <(grep -vE '^\s*#|^\s*$' "$PACKAGE_LIST_FILE")

if [ ${#PACKAGES_TO_REMOVE[@]} -eq 0 ]; then
    display_message "No packages to remove listed in $PACKAGE_LIST_FILE. Exiting."
    exit 0
fi

display_message "The following packages are suggested for removal on $DISTRO:"
for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    echo "- $pkg"
done

echo ""
if ! confirm_action "Do you want to proceed with removing these packages?"; then
    log_info "Debloating cancelled by user."
    exit 0
fi

display_message "Attempting to remove selected packages..."

# Filter out packages that are not currently installed to avoid errors
INSTALLED_PACKAGES=()
for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    if dpkg -s "$pkg" &> /dev/null; then
        INSTALLED_PACKAGES+=("$pkg")
    else
        log_info "Package '$pkg' is not installed, skipping."
    fi
done

if [ ${#INSTALLED_PACKAGES[@]} -eq 0 ]; then
    display_message "No installed packages found from the list to remove. Nothing to do."
else
    log_info "Removing installed packages: ${INSTALLED_PACKAGES[*]}"
    # Using 'apt-get purge' to remove packages and their configuration files
    # Using --assume-yes to avoid prompts within the loop, as confirmation was already given.
    if ! sudo apt-get purge --assume-yes "${INSTALLED_PACKAGES[@]}"; then
        log_error "Failed to remove some packages. Please check the output above for errors."
    else
        log_info "Package removal completed successfully."
    fi
fi


# --- Post-Removal Cleanup ---
display_message "Performing post-removal cleanup..."

# Cleanup operations (normally in cleanup_after_removal.sh, included here for single-file completeness)
log_info "Running 'sudo apt autoremove --purge' to remove unused dependencies..."
if ! sudo apt-get autoremove --purge --assume-yes; then
    log_error "Autoremove failed. Please check for errors."
else
    log_info "Autoremove completed."
fi

log_info "Running 'sudo apt autoclean' to clear local package cache..."
if ! sudo apt-get autoclean --assume-yes; then
    log_error "Autoclean failed. Please check for errors."
else
    log_info "Autoclean completed."
fi

log_info "Cleanup operations finished."
# --- End of Post-Removal Cleanup ---

display_message "Debloating process completed!"
log_info "Your system should now be leaner. Consider restarting for full effect."