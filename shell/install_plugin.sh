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

    # Update placeholders in all copied files
    update_placeholders_in_files "$dest_dir"
}

# Function to update placeholders in a file using Zsh string substitution
update_placeholders_in_files() {
    local dest_dir="$1"

    # Resolve the project root directory
    local project_root=$(cd "$(dirname "$0")/" && pwd)

    # Construct full paths to the config and common scripts
    local config_sh_path="${project_root}/config.sh"
    local common_sh_path="${project_root}/common.sh"

    # Use these paths in the script
    log_info "Config path: $config_sh_path"
    log_info "Common functions path: $common_sh_path"
    log_info "Project root path: $project_root"

    # Loop through all files in the destination directory
    find "$dest_dir" -type f | while read -r file; do
        # Read and replace placeholders
        local file_content=$(<"$file")
        file_content=${file_content//__CONFIG_SH_PATH__/$config_sh_path}
        file_content=${file_content//__COMMON_SH_PATH__/$common_sh_path}
        file_content=${file_content//__PROJECT_ROOT__/$project_root}
        file_content=${file_content//__SCRIPT_PATH__/"$PLUGIN_DEST/$GALAXY_CONTROL_DIR/$GALAXY_CONTROL_PLUGIN_SCRIPT"}

        # Write the modified content back to the file
        echo "$file_content" > "$file"
    done

    if [[ $? -eq 0 ]]; then
        log_info "All placeholders updated in files at $dest_dir"
    else
        log_error "Failed to update placeholders in files at $dest_dir"
        exit 1
    fi
}

# Function to update the plugins array in the ZSH profile to include the galaxy_control plugin
update_plugins_array() {
    plugin_name="$GALAXY_CONTROL_DIR" # name needs to be the same as the directory
    zsh_profile="$ZSH_PROFILE_PATH"
    log_info "Updating the zsh profile at $zsh_profile to load the plugin $plugin_name..." 
    if ! grep -q "$plugin_name" "$zsh_profile"; then
        local temp_file=$(mktemp)
        while read -r line; do
            if [[ "$line" == plugins=\(* ]]; then
                if [[ "$line" != *"$plugin_name"* ]]; then
                    line="${line%\)} $plugin_name)"
                fi
            fi
            echo "$line"
        done < "$zsh_profile" > "$temp_file"
        mv "$temp_file" "$zsh_profile"
        log_info "Added $plugin_name plugin to $zsh_profile"
    else
        log_info "$plugin_name plugin is already present in $zsh_profile"
    fi
}

##############################
######## Script Start ########
##############################

log_info "Starting plugin installation process..."

create_plugin_directory
copy_plugin_files
update_plugin_script
update_plugins_array "$GALAXY_CONTROL_DIR" "$ZSH_PROFILE_PATH" 

log_info "Plugin installation complete."
