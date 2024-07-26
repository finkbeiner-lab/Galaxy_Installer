#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"
source $ZSH_PROFILE_PATH

# Function to move existing galaxy.yml to temporary directory if it exists
move_existing_galaxy_config() {
    if [ -f "$GALAXY_CONFIG_PATH" ]; then
        log_info "Existing galaxy.yml found. Backing it up into the installers temp directory $GALAXY_INSTALLER_TMP_DIR..."
        # Generate a random identifier
        random_id=$(date +%s%N)
        mv "$GALAXY_CONFIG_PATH" "$GALAXY_INSTALLER_TMP_DIR/galaxy.yml.backup.$random_id"
        if [ $? -eq 0 ]; then
            log_info "galaxy.yml moved to $GALAXY_INSTALLER_TMP_DIR/galaxy.yml.backup.$random_id"
        else
            log_error "Failed to move existing galaxy.yml to $GALAXY_INSTALLER_TMP_DIR"
            exit 1
        fi
    else
        log_info "No existing galaxy.yml found. Proceeding with setup..."
    fi
}

# Function to create an admin user in Galaxy through `create_galaxy_admin` python helper script
create_galaxy_admin_user() {
    log_info "Calling out to python helper script to create a galaxy admin user..."
    # Call helper python script and capture output
    "$PYTHON_SCRIPTS_DIR"/call_python_script.sh create_galaxy_admin "$GALAXY_INSTANCE_URL" "$DEFAULT_GALAXY_ADMIN_EMAIL" "$DEFAULT_GALAXY_ADMIN_STARTING_PW" "$DEFAULT_GALAXY_ADMIN_NAME"
    # Capture the python helper script's exit code
    local exit_code=$?
    # Process any failures
    if [ $exit_code -ne 0 ]; then
        log_error "Failed to create Galaxy admin user with output: $output"
        exit $exit_code
    fi
    log_info "Successfully created Galaxy admin user."
}

# Function to install the tools from our tool shed using planemo and the python API
install_tools() {
    log_info "Discovering and installing tools from $TOOL_SHED_DIR/ into Galaxy $GALAXY_DIR/..."
    log_info "Running planemo ci_find_tools to discover tools..."
    tool_files=$(planemo ci_find_tools "$TOOL_SHED_DIR")
    for tool_file in $tool_files; do
        tool_dir=$(dirname "$tool_file")
        log_info "Preparing tool in directory $tool_dir..."
        if [ -f "$tool_dir/.shed.yml" ]; then
            log_info "Installing tool from $tool_dir using Galaxy API..."
            python3 install_tool.py "$tool_dir/.shed.yml" "$GALAXY_API_KEY" "$GALAXY_INSTANCE_URL"
        else
            log_error "Missing .shed.yml in $tool_dir"
            galaxy stop
            exit 1
        fi
    done
    log_info "All tools installed successfully."
}

# Function to verify tools are working
verify_tools() {
    local tool_ids=($(fetch_tool_ids))
    for tool_id in "${tool_ids[@]}"; do
        if ! planemo tool_test --galaxy_root "$GALAXY_DIR" --installed --tool_id "$tool_id"; then
            log_error "Tool $tool_id failed verification."
            galaxy stop
            exit 1
        fi
    done
    log_info "All tools verified successfully."
}

# Function for handling trapped control signals
trap_handler() {
    log_info "🛑🛑🛑🛑 Caught signal $1. Shutting down now... 🛑🛑🛑🛑"
    galaxy stop
    exit 1
}

##############################
######## Script Start ########
##############################

# Intercept ctrl-c and other quit signals to attempt to cleanly stop. Zombie Galaxy is really annoying and easy to end up with.
trap 'trap_handler SIGINT' SIGINT
trap 'trap_handler SIGTERM' SIGTERM

# Start Galaxy in the background and populate global pid variables $nohup_pid and $tail_pid
log_info "We're going to try to start Galaxy. This can take a while the first time (~20min), and sometimes it looks stuck for a minute or two when it isn't."
galaxy start

# Create an admin user for Galaxy and capture API key
log_error "Skipping creating Galaxy Admin User until implemented"
#create_galaxy_admin_user

# Install our tools from our ToolShed repo
log_error "Skipping tool installation until implemented"
# install_tools

# Test a tool from our toolshed
log_error "Skipping verifying tools until implemented"
# verify_tools

galaxy stop
log_info "Galaxy setup complete."

