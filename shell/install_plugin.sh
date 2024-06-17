#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# Function to create the plugin directory if it does not exist
create_plugin_directory() {
    local plugin_dir="$PLUGIN_DEST/$GALAXY_CONTROL_DIR"
    log_info "Creating plugin directory $plugin_dir..."
    if [[ ! -d "$plugin_dir" ]]; then
        mkdir -p "$plugin_dir"
        if [[ $? -eq 0 ]]; then
            log_info "Created plugin directory $plugin_dir"
        else
            log_error "Failed to create plugin directory $plugin_dir"
            exit 1
        fi
    fi
}

# Function to copy plugin files from the control directory to the plugin directory
copy_plugin_files() {
    local source_dir="$GALAXY_CONTROL_DIR"
    local dest_dir="$PLUGIN_DEST/$GALAXY_CONTROL_DIR"
    log_info "Copying plugin files from $source_dir to $dest_dir..."
    cp -rv "${source_dir}/"* "${dest_dir}"
    if [[ $? -eq 0 ]]; then
        log_info "Plugin files copied to $dest_dir"
    else
        log_error "Failed to copy plugin files to $dest_dir"
        exit 1
    fi
}

# Function to update placeholders in the plugin script using Zsh string substitution
update_plugin_script() {
    local source_script="$GALAXY_CONTROL_DIR/$GALAXY_CONTROL_PLUGIN_SCRIPT"
    local dest_script="$PLUGIN_DEST/$GALAXY_CONTROL_DIR/$GALAXY_CONTROL_PLUGIN_SCRIPT"
    local temp_script_path="$GALAXY_INSTALLER_TMP_DIR/temp_plugin_script.zsh"

    # Copy the script to a temporary location
    cp "$source_script" "$temp_script_path"

    # Read and replace placeholders
    local script_content=$(<"$temp_script_path")
   
    # Get the absolute path of the directory above the current script's location.
    # I'm not sure why this is resolving differently than the source call at the top of this file, but ../ is resolving to the wrong directory.
    # As a quick fix, I'm going to remove the parent path out of the call, which resolves to the correct directory.
    # If you know why, update this comment. Thank you.
    local config_directory=$(cd "$(dirname "$0")/" && pwd)

    # Construct full paths to the config and common scripts
    local config_sh_path="${config_directory}/config.sh"
    local common_sh_path="${config_directory}/common.sh"

    # Use these paths in the script
    log_info "Config path: $config_sh_path"
    log_info "Common functions path: $common_sh_path"

    script_content=${script_content//__CONFIG_SH_PATH__/$config_sh_path}
    script_content=${script_content//__COMMON_SH_PATH__/$common_sh_path}
    script_content=${script_content//__SCRIPT_PATH__/"$PLUGIN_DEST/$GALAXY_CONTROL_DIR/$GALAXY_CONTROL_PLUGIN_SCRIPT"}

    # Write the modified content back to the destination
    echo "$script_content" > "$dest_script"

    # Cleanup the temporary file
    rm "$temp_script_path"

    if [[ $? -eq 0 ]]; then
        log_info "Plugin script updated and moved to $dest_script"
    else
        log_error "Failed to update plugin script at $dest_script"
        exit 1
    fi
}

##############################
######## Script Start ########
##############################

log_info "Starting plugin installation process..."

create_plugin_directory
copy_plugin_files
update_plugin_script

log_info "Plugin installation complete."
