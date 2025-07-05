#!/bin/bash

# prompt.sh — Utility for user interaction and confirmations

# Load logger (optional, for consistent output)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils/logger.sh"

# Prompt the user for yes/no confirmation
confirm() {
    local prompt_message="$1"
    local default_answer="${2:-y}"  # Default to 'y' if not specified

    local prompt_suffix="[y/N]"
    [[ "$default_answer" == "y" ]] && prompt_suffix="[Y/n]"

    while true; do
        read -rp "$(echo -e "$(timestamp) [PROMPT] $prompt_message $prompt_suffix: ")" response
        response="${response,,}"  # Convert to lowercase

        if [[ -z "$response" ]]; then
            response="$default_answer"
        fi

        case "$response" in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *)     echo "Please answer yes or no." ;;
        esac
    done
}
