#! /bin/sh
# Provides a common set of utilities for the other scripts

#
# It is important to keep this in lockstep with common.py to retain consistency in the outputs in our shell scripts and python scripts.
#

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
    if [ -z "$GALAXY_INSTALLER_TMP_DIR" ]; then
        log_error "You need to source config.sh where GALAXY_INSTALLER_TMP_DIR is defined."
        exit 1
    fi
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

# Function to create a PID file
create_pid_file() {
    echo $1 > "$GALAXY_INSTALLER_TMP_DIR/$2_pid.txt"
    log_info "Created PID file for $2 with PID $1"
}

# Function to load a PID from a file
load_pid() {
    if [ -f "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt" ]; then
        cat "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt"
    else
        log_error "PID file for $1 not found"
        return 1
    fi
}

# Function to delete a PID file
delete_pid_file() {
    if [ -f "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt" ]; then
        rm "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt"
        log_info "Deleted PID file for $1"
    else
        log_info "No PID file for $1 to delete"
    fi
}
