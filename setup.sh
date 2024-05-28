#! /bin/sh
source "$(dirname "$0")/common.sh"

# Start the overall clock
overall_start_time=$(date +%s)
log_info "Installing Galaxy and its dependencies on macOS..."

# Function to Ensure each script is executable
chmod_scripts() {
    chmod +x \
    install_xcode_tools.sh \
    install_homebrew.sh \
    install_zsh.sh \
    install_oh-my-zsh.sh \
    install_python_3.sh \
    install_tool_shed.sh \
    install_galaxy.sh
}

# Make scripts executable
chmod_scripts
if [ $? -ne 0 ]; then
    log_error "Could not make scripts executable with chmod."
    exit 1
fi

# Stop script timer
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

# Function to run a script and check its exit status
run_script() {
    local script_name=$1
    # Start the script clock
    local script_start_time=$(date +%s)
    
    ./$script_name
    if [ $? -ne 0 ]; then
        local timer_output=$(stop_script_timer $script_start_time $script_name)
        log_error "$timer_output"
        log_error "$script_name failed."
        exit 1
    else
        local timer_output=$(stop_script_timer $script_start_time $script_name)
        log_info "$timer_output"
    fi
}

# Run each script
run_script install_xcode_tools.sh
run_script install_homebrew.sh
run_script install_zsh.sh
run_script install_oh-my-zsh.sh
run_script install_python_3.sh
run script install_tool_shed.sh
run_script install_galaxy.sh

# End the overall clock
end_time=$(date +%s)
elapsed_time=$((end_time - overall_start_time))
elapsed_minutes=$((elapsed_time / 60))
elapsed_seconds=$((elapsed_time % 60))

log_info "Total execution time: $elapsed_minutes minutes $elapsed_seconds seconds"
log_info "Setup completed successfully! 🎉🎉🎉"
