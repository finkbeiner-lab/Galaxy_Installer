#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# Function to create the plugin directory if it does not exist
# Arguments:
#   $1 - Plugin directory path
create_plugin_directory() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
        if [[ $? -eq 0 ]]; then
            log_info "Created plugin directory at $1"
        else
            log_error "Failed to create plugin directory at $1"
            exit 1
        fi
    fi
}

# Function to copy plugin files from the control directory to the plugin directory
# Arguments:
#   $1 - Source directory
#   $2 - Destination directory
copy_plugin_files() {
    cp -r "${1}/"* "${2}"
    if [[ $? -eq 0 ]]; then
        log_info "Plugin files copied to $2"
    else
        log_error "Failed to copy plugin files to $2"
        exit 1
    fi
}

# Function to update the plugins array in the ZSH profile to include the galaxy_control plugin
# Arguments:
#   $1 - Plugin name
#   $2 - ZSH profile path
update_plugins_array() {
    if ! grep -q "$1" "$2"; then
        local temp_file=$(mktemp)
        while read -r line; do
            if [[ "$line" == plugins=\(* ]]; then
                if [[ "$line" != *"$1"* ]]; then
                    line="${line%\)} $1)"
                fi
            fi
            echo "$line"
        done < "$2" > "$temp_file"
        mv "$temp_file" "$2"
        log_info "Added $1 plugin to $2"
    else
        log_info "$1 plugin is already enabled in $2"
    fi
}

##############################
######## Script Start ########
##############################

log_info "Starting plugin installation process..."

create_plugin_directory "$PLUGIN_DEST/galaxy_control"
copy_plugin_files "$GALAXY_CONTROL_DIR" "$PLUGIN_DEST/galaxy_control"
update_plugins_array "galaxy_control" "$ZSH_PROFILE_PATH"

log_info "Plugin installation complete."

