#!/bin/bash

# 99-summary.sh — Final summary and wrap-up

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

LOG_DIR="$SCRIPT_DIR/logs"
BACKUP_DIR="$SCRIPT_DIR/backups"

# Find the most recent log and backup files
LATEST_LOG=$(ls -t "$LOG_DIR"/debloat-*.log 2>/dev/null | head -n 1)
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/installed-packages-*.txt 2>/dev/null | head -n 1)

log_info "🎉 Debloat process completed successfully!"

if [[ -f "$LATEST_LOG" ]]; then
    log_info "📄 Log file saved at: $LATEST_LOG"
fi

if [[ -f "$LATEST_BACKUP" ]]; then
    log_info "📦 Backup of installed packages saved at: $LATEST_BACKUP"
fi

log_info "🔁 It is recommended to reboot your system to apply all changes."
log_success "Thank you for using Ubuntu Debloater!"
