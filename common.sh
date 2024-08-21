#! /bin/sh
# Provides a common set of utilities for the other scripts

#
# It is important to keep this in lockstep with common.py to retain consistency in the outputs in our shell scripts and python scripts.
#

# This grabs the calling script's name in both bash and zsh
script_name=$(basename "${ZSH_ARGZERO:-$0}")

# Function to log informational messages
log_info() {
    local line_number;
    if [ -n "$ZSH_VERSION" ]; then
        # Use funcfiletrace to get the current function's line number in Zsh
        line_number="${funcfiletrace[1]##*:}"
    else
        # Use caller to get the line number in Bash
        line_number=$(caller 0 | awk '{print $1}')
    fi
    echo "\033[0;34m🔬 [INSTALL GALAXY PROJECT] [$script_name:$line_number] $1\033[0m" # Blue
}

# Function to log warning messages
log_warning() {
    local line_number;
    if [ -n "$ZSH_VERSION" ]; then
        # Use funcfiletrace to get the current function's line number in Zsh
        line_number="${funcfiletrace[1]##*:}"
    else
        # Use caller to get the line number in Bash
        line_number=$(caller 0 | awk '{print $1}')
    fi
    echo "\033[0;33m🔬 [WARNING] [$script_name:$line_number] $1\033[0m" # Yellow
}

# Function to log error messages
log_error() {
    local line_number;
    if [ -n "$ZSH_VERSION" ]; then
        # Use funcfiletrace to get the current function's line number in Zsh
        line_number="${funcfiletrace[1]##*:}"
    else
        # Use caller to get the line number in Bash
        line_number=$(caller 0 | awk '{print $1}')
    fi
    echo "\033[0;31m🔬 [ERROR] [$script_name:$line_number] $1\033[0m" >&2 # Red, to stderr
}

# Function to play an alert sound
play_alert_sound() {
    afplay /System/Library/Sounds/Blow.aiff 2>/dev/null || log_warning "Could not play alert sound."
}

# Function to create a PID file from a PID name
create_pid_file() {
    echo $1 > "$GALAXY_INSTALLER_TMP_DIR/$2_pid.txt"
    log_info "Created PID file for $2 with PID $1"
}

# Function to check if a PID could be loaded by PID name
check_for_pid() {
    pid_file="$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt"
    if [[ -e "$pid_file" ]]; then
        pid=$(cat "$pid_file")
        if [[ -n "$pid" ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Function to load a PID by name from its file
load_pid() {
    if [ -f "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt" ]; then
        cat "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt"
    else
        log_error "PID file for $1 not found"
        return 1
    fi
}

# Function to delete a PID file by PID name
delete_pid_file() {
    if [ -f "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt" ]; then
        rm "$GALAXY_INSTALLER_TMP_DIR/$1_pid.txt"
        log_info "Deleted PID file for $1"
    else
        log_info "No PID file for $1 to delete"
    fi
}

# Function to check for an existing galaxy.yml config
check_for_galaxy_config() {
    local galaxy_config_path="$1"
    if [ -f "$galaxy_config_path" ]; then
        if [ ! -w "$galaxy_config_path" ]; then
            log_error "$galaxy_config_path is not writable. Please update file permissions for this file to continue."
            return 1
        fi
        log_info "Existing $galaxy_config_path found."
    else
        log_info "No existing $galaxy_config_path found."
        local galaxy_sample_config_path="$(dirname "$galaxy_config_path")/galaxy.yml.sample"
        start_new_galaxy_config "$galaxy_config_path" "$galaxy_sample_config_path"
    fi
}

# Function to back up a file with a timestamp into the temp directory
backup_file() {
    local file_path="$1"
    if [ -z "$file_path" ]; then
        log_error "File path argument is empty. It must be passed in."
        return 1
    fi
    local temp_dir="$2"
     if [ -z "$temp_dir" ]; then
        log_error "Temporary directory argument is empty. It must be passed in."
        return 1
    fi
    log_info "Backing up $file_path to $temp_dir..."  
    local filename=$(basename "$file_path")
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${filename%.*}_backup_$timestamp.${filename##*.}"
    cp "$file_path" "$temp_dir/$backup_file"
    if [ $? -ne 0 ]; then
        log_error "Backup copy failed. $file_path to $temp_dir/$backup_file"
        return 1
   fi
    log_info "File backed up successfully as $temp_dir/$backup_file"
}


# Function to copy in the sample galaxy.yml
start_new_galaxy_config() {
   local galaxy_config_path="$1"
   if [ -z "$galaxy_config_path" ]; then
        log_error "Galaxy config path argument is empty. It must be passed in."
        return 1
   fi
   local galaxy_sample_config_path="$2"
      if [ -z "$galaxy_sample_config_path" ]; then
        log_error "Galaxy sample config path argument is empty. It must be passed in."
        return 1
   fi
   log_info "Setting up a new config from the sample galaxy.yml..."
   backup_file "$galaxy_config_path" "$GALAXY_INSTALLER_TMP_DIR"
   if [ $? -ne 0 ]; then
        log_error "File backup failed for $galaxy_config_path, we should not continue."
        return 1
   fi
   log_info "Coping over the sample config from $galaxy_sample_config_path to $galaxy_config_path..."
   cp "$galaxy_sample_config_path" "$galaxy_config_path"
   if [ $? -ne 0 ]; then
        log_error "Could not copy $galaxy_sample_config_path to $galaxy_config_path"
        return 1
   fi
   log_info "New galaxy.yml config created successfully at $galaxy_config_path"
}

# Function to create a change in the config (add or modify)
change_galaxy_config() {
    local galaxy_config_path="$1"
    local config_key="$2"
    local config_value="$3"

    if ! check_for_galaxy_config "$galaxy_config_path"; then    
        log_error "Failed to set up a working galaxy.yml config file."
        return 1
    fi

    # Validate the YAML file before making changes
    if ! yq eval '.' "$galaxy_config_path" > /dev/null 2>&1; then
        log_error "The YAML syntax isn't currently correct in $galaxy_config_path, so we will not continue with changing it."
        return 1
    fi

    # Use yq to update the configuration file
    yq eval ".\"$config_key\" = \"$config_value\"" -i "$galaxy_config_path"

    # Validate the YAML file after making changes
    if ! yq eval '.' "$galaxy_config_path" > /dev/null 2>&1; then
        log_error "The YAML syntax check failed after making an update in $galaxy_config_path. This project needs to be debugged for this error."
        return 1
    fi

    log_info "$galaxy_config_path has been updated. $config_key set to $config_value"
}

