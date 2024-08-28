#! /bin/sh

# This script (setup.sh) is the overall runner for all of the intallations.
# There are some implicit depedencies in the ordering of the scripts. But the entire chain is idempotent.

# Start the overall clock
overall_start_time=$(date +%s)

# Bring in common functions and configs
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/common.sh"

# Function to ensure each script is executable
chmod_scripts() {
    # Use an array to collect all file paths
    local -a script_files
    script_files=($(find . -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" \)))
    # Iterate over the array and change permissions
    for script_file in "${script_files[@]}"; do
        chmod +x "$script_file" || {
            log_error "Could not make script executable: $script_file"
            exit 1
        }
    done
    log_info "All scripts made executable successfully."
}

# Function to stop script timer
stop_script_timer() {
    local script_start_time=$1
    local script_name=$2
    # Stop the script clock
    local script_end_time=$(date +%s)
    local script_elapsed_time=$((script_end_time - script_start_time))
    local elapsed_minutes=$((script_elapsed_time / 60))
    local elapsed_seconds=$((script_elapsed_time % 60))
    echo "$script_name script execution time: $elapsed_minutes minutes $elapsed_seconds seconds"
}

# Function to pull in any changes made to ~./zshrc from the previous install script. ~/.zshrc should be kept fast and idempotent, like all profile files.
source_zsh_profile() {
    # In early scripts, the zsh profile may not exist yet, or we may not be running in zsh yet
    if [ -n "$ZSH_VERSION" ] && [ -f "$ZSH_PROFILE_PATH" ]; then 
        source "$ZSH_PROFILE_PATH"
    fi
}

# Function to run a script and check its exit status
run_script() {
    # Source the latest zsh profile
    source_zsh_profile
    # Get the path to the install script to run
    local script=$1
    # Start the script clock
    local script_start_time=$(date +%s)
    # Run it
    $script
    if [ $? -ne 0 ]; then
        local timer_output=$(stop_script_timer $script_start_time $(basename $script))
        log_error "$timer_output"
        log_error "$script failed."
        exit 1
    else
        local timer_output=$(stop_script_timer $script_start_time $(basename $script))
        log_info "$timer_output"
    fi
}

# Function to check if the directory exists and create it or clear it if it already exists
create_installer_tmp_directory() {
    # Make sure we're in project root
    cd "$(dirname "$0")"
    if [ -d "$GALAXY_INSTALLER_TMP_DIR" ]; then
        log_info "Directory $GALAXY_INSTALLER_TMP_DIR already exists. Clearing it out..."
        # Clear the directory
        rm -rf "$GALAXY_INSTALLER_TMP_DIR"/*
        if [ $? -ne 0 ]; then
            log_error "Failed to clear out directory $GALAXY_INSTALLER_TMP_DIR."
            exit 1
        fi
    else
        log_info "Directory $GALAXY_INSTALLER_TMP_DIR does not exist. Creating it..."
        mkdir -p "$GALAXY_INSTALLER_TMP_DIR"
        if [ $? -ne 0 ]; then
            log_error "Failed to create directory $GALAXY_INSTALLER_TMP_DIR."
            exit 1
        fi
    fi
    log_info "Directory $GALAXY_INSTALLER_TMP_DIR prepared successfully."
}

###############################
######## Script Start ########
##############################

# Change to the root directory of the project
# Every script called will begin in this directory. This is important for correctly resolving paths.
cd "$(dirname "$0")"

# Create or clear out our temp directory
# This needs to happen early as it will contain the log from this file, and logging above it probably explodes.
create_installer_tmp_directory

log_info "Installing Galaxy and its dependencies on macOS..."

# Make scripts executable
chmod_scripts

# Run each script
run_script "$SHELL_SCRIPTS_DIR/install_xcode_tools.sh"
run_script "$SHELL_SCRIPTS_DIR/install_homebrew.sh"
run_script "$SHELL_SCRIPTS_DIR/install_zsh.sh"
run_script "$SHELL_SCRIPTS_DIR/install_oh-my-zsh.sh"
run_script "$SHELL_SCRIPTS_DIR/install_yq.sh"
run_script "$SHELL_SCRIPTS_DIR/install_python_3.sh"
run_script "$SHELL_SCRIPTS_DIR/install_pipx.sh"
run_script "$SHELL_SCRIPTS_DIR/clone_galaxy_repo.sh"
run_script "$SHELL_SCRIPTS_DIR/install_plugin.sh"
run_script "$SHELL_SCRIPTS_DIR/install_tool_shed.sh"
run_script "$SHELL_SCRIPTS_DIR/install_galaxy.sh"

# End the overall clock
end_time=$(date +%s)
elapsed_time=$((end_time - overall_start_time))
elapsed_minutes=$((elapsed_time / 60))
elapsed_seconds=$((elapsed_time % 60))

# Finish up
log_info "Total execution time: $elapsed_minutes minutes $elapsed_seconds seconds"
log_info "You did it!"
log_info "galaxy start and galaxy stop shortcuts have been added for you. They will work in any terminals you open after this one. To use them now, first run: source $ZSH_PROFILE_PATH"
log_info "Setup completed successfully! 🎉🎉🎉"

