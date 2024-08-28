#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# We'll be explicity using the galaxy control plugin in this script, so we need to make sure any changes to the zsh profile are updated in the context (these changes don't propogate once this script exits)
source $ZSH_PROFILE_PATH

# Function to configure Galaxy to use Conda by changing the galaxy.yml
configure_galaxy_for_conda() {
    log_info "Configuring Galaxy to use Conda..."
    conda_prefix=$(conda info --base)
    log_info "Conda prefix: $conda_prefix"
    conda_exec=$(command -v conda)
    log_info "Conda executable: $conda_exec"
    change_galaxy_config "$GALAXY_CONFIG_PATH" "conda.prefix" "$conda_prefix"
    local first_result=$?
    change_galaxy_config "$GALAXY_CONFIG_PATH" "dependency_resolvers[0].conda_exec" "$conda_exec"
    local second_result=$?
    if [ $first_result -ne 0 ] || [ $second_result -ne 0 ]; then
        log_error "Galaxy wasn't configured to use Conda successfully. There is an issue with galaxy.yml."
        exit 1
    else
        log_info "Galaxy configured to use Conda successfully."
    fi
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

# Configure Galaxy to use Conda
configure_galaxy_for_conda

# Create an API key in the Galaxy config
log_error "TODO: API key"

# Start Galaxy in the background and populate global pid variables $nohup_pid and $tail_pid
log_info "We're going to try to start Galaxy. This can take a while the first time (~20min) while Galaxy does some installation and configuration,, and sometimes it looks stuck for a minute or two when it isn't."
galaxy start

# Install our tools from our ToolShed repo
log_error "Skipping tool installation until implemented"
# install_tools

# Test a tool from our toolshed
log_error "Skipping verifying tools until implemented"
# verify_tools

galaxy stop
log_info "Galaxy setup complete."

