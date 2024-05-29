#! /bin/sh
# Provides a common set of utilities for the other scripts

source "$(dirname "$0")/config.sh"

# Function to log informational messages
log_info() {
    echo "\033[0;34m🔬 [INSTALL GALAXY PROJECT] $1\033[0m" # Blue
}

# Function to log warning messages
log_warning() {
    echo "\033[0;33m🔬 [WARNING] $1\033[0m" # Yellow
}

# Function to log error messages
log_error() {
    echo "\033[0;31m🔬 [ERROR] $1\033[0m" >&2 # Red, to stderr
}

# Function to play an alert sound
play_alert_sound() {
    afplay /System/Library/Sounds/Blow.aiff 2>/dev/null || log_warning "Failed to play alert sound."
}

# Function to check if the directory exists and create it if not
ensure_tmp_directory_exists() {
    if [ ! -d "$GALAXY_INSTALLER_TMP_DIR" ]; then
        log_info "Directory $GALAXY_INSTALLER_TMP_DIR does not exist. Creating it..."
        mkdir -p "$GALAXY_INSTALLER_TMP_DIR"
        if [ $? -eq 0 ]; then
            log_info "Directory $GALAXY_INSTALLER_TMP_DIR created successfully."
        else
            log_error "Failed to create directory $GALAXY_INSTALLER_TMP_DIR."
            exit 1
        fi
    fi
}

