#!/bin/zsh
# galaxy_control.plugin.zsh

# This plugin script is designed to be sourced by zsh when it is loading plugins.
# It sets up the shell context to know about 'galaxy start' and 'galaxy stop' etc.

### Instructions for uninstallation and manual cleanup ###
# Please follow the instructions below if you need to uninstall the Galaxy plugin:
# 1. Remove the plugin entry, called galaxy_control, from your zsh profile, usually found in ~/.zshrc
# 2. Delete the plugin directory this script lives in.

# Hard-coded paths set during installation
# These must be hard-coded absolute paths, because sourced scripts do not have context on where they live (outside of shell-specific magic functions).
# Nor is there any way to resolve where our common.sh and config.sh files have been installed on the machine at runtime without forcing them or a pointer file to be stored in a specific place.
# If these look like __<FOO>__ instead of an actual path, the installer failed to update the placeholder variables.
# If you have moved the Galaxy Installer's directory, you can manually update these paths to reattach them.
PROJECT_ROOT="__PROJECT_ROOT__"
SCRIPT_PATH="__SCRIPT_PATH__"  # The path to this plugin script, shell scripts called by this plugin are expected to be siblings of its location.

# Function to source required configuration files
source_configs() {
    source "$PROJECT_ROOT/config.sh"
    source "$PROJECT_ROOT/common.sh"
}

# Function to display standard usage help
display_usage() {
    echo "Usage:"
    echo "  galaxy start  - Start Galaxy"
    echo "  galaxy stop   - Stop Galaxy"
}

# Function for configuration issues help
display_config_help() {
    echo "Error: Unable to load configuration or common scripts from the Install Galaxy root directory (sunch as config.sh and common.sh)."
    echo "Please ensure the Galaxy Installer directory has not been moved or deleted."
    if [[ -n "$SCRIPT_PATH" ]]; then
        echo "This script is located at $SCRIPT_PATH"
        echo "To uninstall or troubleshoot, read through $SCRIPT_PATH and follow the directions within."
    else
        echo "Script path was not set. So we cannot resolve where galaxy_control.plugin.zsh exists on your machine to help you fix it."
        echo "However, you can track down galaxy_control.plugin.zsh (perhaps where oh-my-zsh stores plugins, or whatever else you are using to manage zsh plugins) and fix it manually."
        echo "Alternatively, you can try re-running the Galaxy Installer, which will reinstall the plugin. It also outputs the location it is installing it to if you can't find it."
    fi
}

# Function to ensure the temp directory is still around
find_or_create_installer_temp_directory() {
    log_info "Checking for Galaxy Installer temp directory..."
    if [ !  -d "$PROJECT_ROOT/$GALAXY_INSTALLER_TMP_DIR" ]; then
        log_info "Install Galaxy temp directory has been moved or deleted. Attempting to recreate it..."
        if [ -n "$PROJECT_ROOT" &&  -n "$GALAXY_INSTALLER_TMP_DIR" ]; then
            mkdir -p "$PROJECT_ROOT/$GALAXY_INSTALLER_TMP_DIR"
            if [ $? -eq 0 ]; then
                log_info "Install Galaxy temp directory was recreated successfully."
                return 0
            else
                log_error "Failed to create the temporary directory. Perhaps the Install Galaxy project was moved or deleted, or we don't have permission."
                return 1
            fi
        else
            log_error "Install Galaxy temp directory path wasn't resolved: $PROJECT_ROOT/$GALAXY_INSTALLER_TMP_DIR"
            log_error "Cannot recreate Galaxy temp directory do to some kind of path configuration error. Displaying config help..."
            display_config_help
            return 1
        fi
    else 
        log_info "Galaxy Installer temp directory found ($PROJECT_ROOT/$GALAXY_INSTALLER_TMP_DIR)"
        return 0
    fi
}

# In usage within galaxy function or other places
galaxy() {
   # Source latest configs
   source_configs
   
   # Make sure we have a temp directory for logs and pids
    if ! find_or_create_installer_temp_directory; then
        return 1
    fi

    # Resolve the absolute path to the plugin directory, which will contain the installed plugin's scripts 
    local script_dir="$(dirname $SCRIPT_PATH)"
    log_info "Note: Line numbers and script names in log messages are often incorrect when calling from another script into the Galaxy control plugin."

    case "$1" in
        start)
            # Pull the latest copy of the start function
            source "$script_dir/galaxy_start.sh"
            # Start Galaxy and send along extra params
            start_galaxy "${@:2}"
            ;;
        stop)
            # Pull the latest copy of the start function
            source "$script_dir/galaxy_stop.sh"
            # Stop Galaxy and send along extra params
            stop_galaxy "${@:2}"
            ;;
        *)
            display_usage
            return 1
            ;;
    esac
}

