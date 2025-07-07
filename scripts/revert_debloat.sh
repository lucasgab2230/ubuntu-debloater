#!/bin/bash
# scripts/revert_debloat.sh
# Script to attempt to revert common changes made by the Ubuntu Debloater.
# This script aims to reinstall packages that are frequently removed as bloatware,
# offering a potential safety net if essential functionality was inadvertently lost.

# WARNING: This script is EXPERIMENTAL.
# It does NOT guarantee a full restoration of your system to its previous state.
# It only attempts to reinstall a predefined list of commonly removed packages.
# Always have a full system backup before performing any debloating or reverting actions.

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# --- Common functions (for logging and user interaction) ---
# Assuming these functions are either sourced from functions.sh or defined here for standalone use.
# For this complete block, we'll include them.

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
    exit 1 # Exit on error for this script
}

display_message() {
    echo ""
    echo "----------------------------------------------------"
    echo "$1"
    echo "----------------------------------------------------"
    echo ""
}

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure apt is available
if ! command_exists apt; then
    log_error "APT package manager not found. This script requires APT."
fi

# --- List of commonly removed packages to reinstall ---
# This list should include packages that are often removed by debloaters
# and might be desired back by users. It's a general "restore" list.
PACKAGES_TO_REINSTALL=(
    # Office Suite
    libreoffice-writer
    libreoffice-calc
    libreoffice-impress
    libreoffice-draw
    libreoffice-math
    libreoffice-base
    libreoffice-gnome # For GNOME integration
    libreoffice-kde   # For KDE integration
    libreoffice-gtk3  # For GTK3 integration
    thunderbird       # Email client

    # Multimedia & Graphics
    rhythmbox         # GNOME music player
    totem             # GNOME video player
    shotwell          # Photo manager
    cheese            # Webcam application
    gnome-characters  # Character map
    simple-scan       # Document scanner
    gwenview          # KDE image viewer
    dragonplayer      # KDE video player
    parole            # XFCE media player
    ristretto         # XFCE image viewer
    xfburn            # XFCE CD/DVD burning

    # Internet & Communication
    remmina
    remmina-plugin-vnc
    remmina-plugin-secret
    remmina-plugin-rdp
    pidgin            # Instant messaging client
    hexchat           # IRC client (Linux Mint)
    transmission-gtk  # BitTorrent client (Linux Mint/Ubuntu)
    transmission-qt   # BitTorrent client (Lubuntu)
    qBittorrent       # BitTorrent client (Lubuntu)
    konversation      # KDE IRC client
    kdeconnect        # KDE phone integration
    kmail             # KDE email client
    korganizer        # KDE calendar
    kaddressbook      # KDE address book

    # Games
    gnome-mahjongg
    gnome-mines
    gnome-sudoku
    aisleriot
    quadrapassel
    hitori
    lightsoff
    swell-foop
    kmahjongg         # KDE games
    kmines
    ksudoku
    kpat
    kblocks

    # System Utilities & Desktop Environment Components
    gnome-disk-utility  # Disk Usage Analyzer
    gnome-system-monitor # System Monitor
    gnome-todo          # GNOME To Do app
    yelp                # Help documentation viewer
    apport              # Crash reporting
    apport-gtk
    whoopsie            # Crash submission daemon
    popularity-contest  # Usage statistics
    timeshift           # System restore tool (Linux Mint - highly recommended to keep)
    discover            # Software Center (KDE Plasma)
    plasma-discover-backend-flatpak
    plasma-discover-backend-snap
    plasma-discover-backend-fwupd
    xfce4-taskmanager   # XFCE Task Manager
    xfce4-screenshooter # XFCE Screenshot tool
    orage               # XFCE Calendar
    xviewer             # Linux Mint Image Viewer
    xreader             # Linux Mint Document Viewer
    xed                 # Linux Mint Text Editor
    xplayer             # Linux Mint Media Player
    hypnotix            # Linux Mint IPTV player
    drawing             # Linux Mint simple drawing app
    webapp-manager      # Linux Mint web app creator
    mintreport          # Linux Mint system reports
    mintstick           # Linux Mint USB formatter
    qlipper             # Lubuntu clipboard manager
    lximage-qt          # Lubuntu image viewer/editor
    galculator          # Lubuntu calculator
    leafpad             # Lubuntu text editor

    # Accessibility
    gnome-orca
    orca
    brltty
    speech-dispatcher
    speech-dispatcher-audio-plugins
    speech-dispatcher-espeak-ng

    # Other
    example-content     # Example documents/pictures
)

# --- Main Script Logic ---

display_message "Starting Revert Debloater (EXPERIMENTAL)..."
log_info "This script will attempt to reinstall commonly removed packages."
log_info "It does NOT guarantee a full system restoration."

echo ""
if ! confirm_action "Do you understand the experimental nature and wish to proceed with reinstalling packages?"; then
    log_info "Reversion cancelled by user."
    exit 0
fi

display_message "Attempting to reinstall selected packages..."

# Filter out packages that are already installed to avoid unnecessary operations
# and only attempt to install those that are missing.
MISSING_PACKAGES=()
for pkg in "${PACKAGES_TO_REINSTALL[@]}"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        MISSING_PACKAGES+=("$pkg")
    else
        log_info "Package '$pkg' is already installed, skipping reinstallation."
    fi
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    display_message "All selected packages are already installed. Nothing to reinstall."
    log_info "Reversion process completed (no action taken as packages were present)."
    exit 0
fi

log_info "Packages to be reinstalled: ${MISSING_PACKAGES[*]}"

# Reinstall packages
# Using 'apt-get install' to reinstall packages
# Using --assume-yes to avoid prompts
if ! sudo apt-get install --assume-yes "${MISSING_PACKAGES[@]}"; then
    log_error "Failed to reinstall some packages. Please check the output above for errors."
    log_info "Reversion process completed with errors."
else
    log_info "Package reinstallation completed successfully."
    log_info "Reversion process completed!"
    log_info "Consider running 'sudo apt autoremove --purge' and 'sudo apt autoclean' afterwards."
    log_info "A system restart might be beneficial for full effect."
fi
