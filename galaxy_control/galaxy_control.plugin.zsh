#!/bin/zsh
# galaxy_control.plugin.zsh

# This plugin script is designed to be sourced by zsh when it is loading plugins.
# It sets up the shell context to know about 'galaxy start' and 'galaxy stop' etc.

# Hard-coded paths set during installation
# These must be hard-coded absolute paths, because sourced scripts do not have context on where they live (outside of shell-specific magic functions).
# Nor is there any way to resolve where our common.sh and config.sh files have been installed on the machine at runtime without forcing them or a pointer file to be stored in a specific place.
# If these look like __<FOO>__ instead of an actual path, the installer failed to update the placeholder variables.
# If you have moved the Galaxy Installer's directory, you can manually update these paths to reattach them.
PROJECT_ROOT="__PROJECT_ROOT__"
SCRIPT_PATH="__SCRIPT_PATH__"  # The path to this plugin script, shell scripts called by this plugin are expected to be siblings of its location.

# Function to display standard usage help
display_usage() {
    echo "Usage:"
    echo "  galaxy start  - Start Galaxy"
    echo "  galaxy stop   - Stop Galaxy"
}

# Function for configuration issues help
display_config_help() {
    echo "Error: Unable to load configuration or common scripts from the Install Galaxy root directory (config.sh and common.sh)."
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
create_installer_tmp_directory() {
    # Make sure we're in project root
    cd "$PROJECT_ROOT"
    if [ -n "$GALAXY_INSTALLER_TMP_DIR" ]; then
        mkdir -p "$GALAXY_INSTALLER_TMP_DIR"
    fi
}

# Function to validate and source required configuration files
source_configs() {
    if [[ -f "$PROJECT_ROOT/config.sh" && -f "$PROJECT_ROOT/common.sh" ]]; then
        source "$PROJECT_ROOT/config.sh"
        source "$PROJECT_ROOT/common.sh"
    else
        display_config_help
        return 1  # Return failure status to the caller
    fi
    return 0  # Return success status
}

# In usage within galaxy function or other places
galaxy() {
    if ! source_configs; then  # Check configuration each time the function is called
        return 1  # Stop further execution and preserve the session
    fi

    local script_dir="$(dirname $SCRIPT_PATH)" 

    case "$1" in
        start)
            source "$script_dir/galaxy_start.sh"
            start_galaxy "${@:2}"
            ;;
        stop)
            source "$script_dir/galaxy_stop.sh"
            stop_galaxy "${@:2}"
            ;;
        *)
            display_usage
            return 1
            ;;
    esac
}

# Create temp directory if it doesn't exist
create_installer_tmp_directory

### Instructions for uninstallation and manual cleanup ###
# Please follow the instructions below if you need to uninstall the Galaxy plugin:
# 1. Remove the plugin entry, galaxy_control, from your zsh profile, such as ~/.zshrc
# 2. Delete the plugin directory this script lives in.
