#! /bin/sh
# Provides a common set of utilities for the other scripts

source "$(dirname "$0")/config.sh"

# Function to log informational messages
log_info() {
    echo "\033[0;34m🔬 [INSTALL GALAXY PROJECT] $1\033[0m"  # Blue
}

# Function to log error messages
log_error() {
    echo "\033[0;31m🔬 [ERROR] $1\033[0m" >&2  # Red, to stderr
}

# Function to play an alert sound
play_alert_sound() {
    afplay /System/Library/Sounds/Blow.aiff 2>/dev/null || log_warning "Failed to play alert sound."
}

