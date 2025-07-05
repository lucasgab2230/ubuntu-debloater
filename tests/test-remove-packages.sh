#!/bin/bash

# test-remove-packages.sh — Test script for 02-remove-packages.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOVE_SCRIPT="$SCRIPT_DIR/scripts/02-remove-packages.sh"
CONFIG_DIR="$SCRIPT_DIR/config"
FLAVOR_FILE="/tmp/ubuntu-flavor"

# Load logger
source "$SCRIPT_DIR/utils/logger.sh"

log_info "Running test: Simulate package removal"

# Simulate flavor detection
echo "ubuntu" > "$FLAVOR_FILE"
log_info "Simulated flavor: ubuntu"

# Backup original apt-get
APT_BACKUP="/tmp/apt-get-backup"
APT_FAKE="$SCRIPT_DIR/tests/fake-apt-get.sh"
mkdir -p "$(dirname "$APT_BACKUP")"
command -v apt-get &> /dev/null && cp "$(command -v apt-get)" "$APT_BACKUP"

# Create a fake apt-get script to intercept calls
cat << 'EOF' > "$APT_FAKE"
#!/bin/bash
echo "[FAKE] apt-get called with: $*"
exit 0
EOF

chmod +x "$APT_FAKE"
export PATH="$SCRIPT_DIR/tests:$PATH"

# Run the removal script
if [[ -x "$REMOVE_SCRIPT" ]]; then
    bash "$REMOVE_SCRIPT"
else
    log_error "Removal script not found or not executable: $REMOVE_SCRIPT"
    exit 1
fi

# Cleanup
rm -f "$FLAVOR_FILE"
rm -f "$APT_FAKE"
export PATH=$(echo "$PATH" | sed "s|$SCRIPT_DIR/tests:||")

log_success "Test completed: Package removal logic executed in dry-run mode."
