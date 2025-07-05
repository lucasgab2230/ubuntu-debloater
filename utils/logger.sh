#!/bin/bash

# logger.sh — Logging utility with color-coded output

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Timestamp
timestamp() {
    date +"[%Y-%m-%d %H:%M:%S]"
}

# Log functions
log_info() {
    echo -e "$(timestamp) ${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "$(timestamp) ${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "$(timestamp) ${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "$(timestamp) ${RED}[ERROR]${NC} $1" >&2
}
