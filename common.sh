#! /bin/sh
# Provides a common set of utilities for the other scripts

#
# It is important to keep this in lockstep with common.py to retain consistency in the outputs in our shell scripts and python scripts.
#

# This grabs the calling script's name in both bash and zsh, with a check for invalid `ZSH_ARGZERO`.
script_name=$(basename -- "${ZSH_ARGZERO:-$0}")
if [[ "$script_name" == -* ]]; then
    script_name=$(basename -- "$0")
fi

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

# Function to delete unused files from a directory
# Optional parameter to keep all files newer than a given ISO 8601 timestamp
# Optional parameter to keep a number of the newest files regardless of timestamp
clean_directory() {
    local directory="$1" # No default value, must be provided
    local timestamp="${2:-$(date -u +"%Y-%m-%d %H:%M:%S")}" # Default to current time in find-compatible format
    local min_files_to_keep="${3:-0}" # Default to 0
    # Check if the directory exists
    if [ ! -d "$directory" ]; then
        log_error "Directory '$directory' for cleaning does not exist."
        return 1
    fi
    # Check if the script has read and write permissions for the directory
    if [ ! -r "$directory" ] || [ ! -w "$directory" ]; then
        log_error "Permission denied: Cannot read or write to directory '$directory'. Cannot continue with clean."
        return 1
    fi
    # Count the number of files in the directory
    local file_count=$(find "$directory" -type f | wc -l | xargs)
    # Calculate the number of files to delete
    local files_to_delete=$(($file_count - $min_files_to_keep))
    # Delete any files we need to
    if [ "$files_to_delete" -gt 0 ]; then
        find "$directory" -type f ! -newermt "$timestamp" | sort | head -n "$files_to_delete" | xargs -I {} rm --
        if [ $? -ne 0 ]; then
            log_error "Failed to delete files in directory '$directory'."
            return 1
        fi
        log_info "Cleaned directory '$directory'. Deleted $files_to_delete file(s) older than the given timestamp, keeping the $min_files_to_keep most recent files."
    else
        log_info "No files to delete. The directory has $file_count files, which is less than or equal to the minimum required files to keep ($min_files_to_keep)."
    fi
}

# Function to create a PID file from a PID name
create_pid_file() {
    echo $1 > "$GALAXY_INSTALLER_TEMP_DIR/$2_pid.txt"
    log_info "Created PID file for $2 with PID $1"
}

# Function to check if a PID could be loaded by PID name
check_for_pid() {
    pid_file="$GALAXY_INSTALLER_TEMP_DIR/$1_pid.txt"
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
    if [ -f "$GALAXY_INSTALLER_TEMP_DIR/$1_pid.txt" ]; then
        cat "$GALAXY_INSTALLER_TEMP_DIR/$1_pid.txt"
    else
        log_error "PID file for $1 not found"
        return 1
    fi
}

# Function to delete a PID file by PID name
delete_pid_file() {
    if [ -f "$GALAXY_INSTALLER_TEMP_DIR/$1_pid.txt" ]; then
        rm "$GALAXY_INSTALLER_TEMP_DIR/$1_pid.txt"
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
    if [ ! -f "$file_path" ]; then
        log_error "$file_path not found, nothing to back up."
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
   if [ -f "$galaxy_config_path" ]; then
        backup_file "$galaxy_config_path" "$GALAXY_INSTALLER_TEMP_DIR"
       if [ $? -ne 0 ]; then
            log_error "File backup failed for $galaxy_config_path, we should not continue."
            return 1
       fi
   fi
   log_info "Setting up a new config from the sample galaxy.yml..."
   log_info "Coping from $galaxy_sample_config_path to $galaxy_config_path..."
   cp "$galaxy_sample_config_path" "$galaxy_config_path"
   if [ $? -ne 0 ]; then
        log_error "Could not copy $galaxy_sample_config_path to $galaxy_config_path"
        return 1
   fi
   log_info "New galaxy.yml config created successfully at $galaxy_config_path"
}

# Function to create or modify a config key/value pair, handling commented-out keys
change_galaxy_config() {
    local galaxy_config_path="$1"
    local full_config_key_path="$2"
    local config_value="$3"
    if ! check_for_galaxy_config "$galaxy_config_path"; then    
        log_error "Failed to set up a working galaxy.yml config file."
        return 1
    fi
    # Uncomment the key if it's commented out
    sed -i.bak -E "s/^#\s*($full_config_key_path\s*:.*)/\1/" "$galaxy_config_path"
    # Validate the YAML file before making changes
    if ! yq eval '.' "$galaxy_config_path" > /dev/null 2>&1; then
        log_error "The YAML syntax isn't currently correct in $galaxy_config_path, so we will not continue with changing it."
        return 1
    fi
    # Modify the key based on the full path provided
    yq eval ".${full_config_key_path} = \"$config_value\"" -i "$galaxy_config_path"
    # Validate the YAML file after making changes
    if ! yq eval '.' "$galaxy_config_path" > /dev/null 2>&1; then
        log_error "The YAML syntax check failed after making an update in $galaxy_config_path. This project needs to be debugged for this error."
        return 1
    fi
    log_info "$galaxy_config_path has been updated. ${full_config_key_path} set to $config_value"
}
