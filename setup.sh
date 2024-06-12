#! /bin/sh

# This script (setup.sh) is the overall runner for all of the intallations.
# There are some implicit depedencies in the ordering of the scripts. But the entire chain is idempotent.

# Start the overall clock
overall_start_time=$(date +%s)

# Bring in common functions and configs
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/common.sh"

log_info "Installing Galaxy and its dependencies on macOS..."

# Change to the root directory of the project
cd "$(dirname "$0")"

# Function to ensure each script is executable
chmod_scripts() {
    find . -type f \( -name "*.py" -o -name "*.sh" \) -exec chmod +x {} \;
}

# Function to make scripts executable
chmod_scripts
if [ $? -ne 0 ]; then
    log_error "Could not make scripts executable with chmod."
    exit 1
fi

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
source_zshrc() {
    # In early scripts, ~/.zshrc may not exist yet, and we may not be running in zsh
    if [ -n "$ZSH_VERSION" ] && [ -f "$HOME/.zshrc" ]; then    
        source "$HOME/.zshrc"
    fi
}

# Function to run a script and check its exit status
run_script() {
    # Source the latest zsh profile
    source_zshrc
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

###############################
######## Script Start ########
##############################


# Run each script
run_script "$SHELL_SCRIPTS_DIR/install_xcode_tools.sh"
run_script "$SHELL_SCRIPTS_DIR/install_homebrew.sh"
run_script "$SHELL_SCRIPTS_DIR/install_zsh.sh"
run_script "$SHELL_SCRIPTS_DIR/install_oh-my-zsh.sh"
run_script "$SHELL_SCRIPTS_DIR/install_yq.sh"
run_script "$SHELL_SCRIPTS_DIR/install_python_3.sh"
run_script "$SHELL_SCRIPTS_DIR/install_pipx.sh"
run_script "$SHELL_SCRIPTS_DIR/add_conda_to_galaxy_config.sh"
run_script "$SHELL_SCRIPTS_DIR/install_tool_shed.sh"
run_script "$SHELL_SCRIPTS_DIR/clone_galaxy_repo.sh"
run_script "$SHELL_SCRIPTS_DIR/install_galaxy.sh"

# End the overall clock
end_time=$(date +%s)
elapsed_time=$((end_time - overall_start_time))
elapsed_minutes=$((elapsed_time / 60))
elapsed_seconds=$((elapsed_time % 60))

# Finish up
log_info "Total execution time: $elapsed_minutes minutes $elapsed_seconds seconds"
log_info "Setup completed successfully! 🎉🎉🎉"

