#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# We'll be explicity using the galaxy control plugin in this script, so we need to make sure any changes to the zsh profile are updated in the context (these changes don't propogate once this script exits)
source $ZSH_PROFILE_PATH

# Function to configure Galaxy to use Conda by changing the galaxy.yml
configure_galaxy_for_conda() {
    log_info "Configuring Galaxy to use Conda..."
    
    # Get the Conda prefix and executable path
    conda_prefix=$(conda info --base)
    log_info "Conda prefix: $conda_prefix"
    conda_exec=$(command -v conda)
    log_info "Conda executable: $conda_exec"
    
    # Update the galaxy.yml file with the correct structure
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.conda.prefix" "$conda_prefix"
    local first_result=$?
    
    # Ensure that the dependency resolver includes a type
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.dependency_resolvers[0].type" "conda"
    local type_result=$?
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.dependency_resolvers[0].conda_exec" "$conda_exec"
    local second_result=$?
    
    # Check if all updates were successful
    if [ $first_result -ne 0 ] || [ $type_result -ne 0 ] || [ $second_result -ne 0 ]; then
        log_error "Galaxy wasn't configured to use Conda successfully. There is an issue with galaxy.yml."
        exit 1
    else
        log_info "Galaxy configured to use Conda successfully."
    fi
}

# Function to configure Galaxy admin user details in the Galaxy configuration
configure_galaxy_admin_user() {
    log_error "Making change to welcome_url field for testing..."
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.welcome_url" "http://www.froctopus.com/"
    log_info "Configuring Galaxy admin user..."
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.admin_users" "$DEFAULT_GALAXY_ADMIN_EMAIL"
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.admin_password" "$DEFAULT_GALAXY_ADMIN_STARING_PW"
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.admin_api_key" "$DEFAULT_GALAXY_ADMIN_API_KEY"
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.admin_user_name" "$DEFAULT_GALAXY_ADMIN_NAME"
    change_galaxy_config "$GALAXY_CONFIG_FILE" "galaxy.conda.prefix" "/Users/benjaminbrumbaugh/miniconda3"
    
    if [ $? -ne 0 ]; then
        log_error "Failed to configure Galaxy admin user details in $GALAXY_CONFIG_FILE."
        exit 1
    else
        log_info "Galaxy admin user details configured successfully in $GALAXY_CONFIG_FILE."
    fi
}

# Function to install the tools from our ToolShed repo using BioBlend
install_tools() {
    log_info "Installing tools into Galaxy using BioBlend..."
    # Call the Python script to install tools using zsh
    zsh "$PYTHON_HELPER_SCRIPT" "install_tools" "--api_key" "$DEFAULT_GALAXY_ADMIN_API_KEY" "--galaxy_url" "$GALAXY_INSTANCE_URL" "--repository_name" "$TOOL_SHED_NAME" "--repository_owner" "$TOOL_SHED_OWNER_NAME"
    if [ $? -ne 0 ]; then
        log_error "Tool installation failed with python helper."
        galaxy stop
        exit 1
    fi
    log_info "Tools installed successfully."
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

# Configure Galaxy to use Conda
configure_galaxy_for_conda

# Configure the Admin user
configure_galaxy_admin_user

# Start Galaxy in the background and populate global pid variables $nohup_pid and $tail_pid
log_info "We're going to try to start Galaxy. This can take a while the first time (~20min) while Galaxy does some installation and configuration,, and sometimes it looks stuck for a minute or two when it isn't."
galaxy start

# Install our tools from our ToolShed repo
install_tools

# Test a tool from our toolshed
log_error "Skipping verifying tools until implemented"
# verify_tools

galaxy stop
log_info "Galaxy setup complete."

