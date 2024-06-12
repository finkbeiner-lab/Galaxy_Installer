#!/bin/sh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

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

# Function to start Galaxy in the background
start_galaxy() {
    log_info "Starting up Galaxy..."
    # We start Galaxy in a nohup instead of using it's own daemon so we can grab the pid and kill it. Galaxy's own pidfile isn't showing up, and we were getting zombies.
    nohup "$GALAXY_DIR"/run.sh start &> "$GALAXY_INSTALLER_TMP_DIR/install_galaxy.log" &
    nohup_pid=$! # Global
    log_info "Captured run.sh's nohup pid as $nohup_pid"
    tail -F "$GALAXY_INSTALLER_TMP_DIR/install_galaxy.log" &
    tail_pid=$! # Global
    log_info "Captured tail's pid as $tail_pid"
    # Let's give Galaxy some time to establish its processes, it won't be ready for a while anyway
    sleep 5
}

# Function to check if Galaxy is up by querying the main page
check_galaxy() {
    log_info "Checking to see if Galaxy is responsive..."
    for i in {1..600}; do  # Check for up to 30 minutes
        if curl -s $GALAXY_INSTANCE_URL | grep -q 'Galaxy'; then
            log_info "Galaxy is live and responsive on $GALAXY_INSTANCE_URL 🥳"
            return 0
        fi
        log_info "Waiting for Galaxy server to spin up... $i/600"
        sleep 3
    done
    log_error "Galaxy server did not start successfully. Take a peak at $GALAXY_INSTALLER_TMP_DIR/install_galaxy.log and $GALAXY_DIR/galaxy.log"
    shutdown_galaxy_with_error
}

# Function to create an admin user in Galaxy through `create_galaxy_admin` python helper script
create_galaxy_admin_user() {
    log_info "Calling out to python helper script to create a galaxy admin user..."
    # Call helper python script and capture output
    local output=$("$PYTHON_SCRIPTS_DIR"/call_python_script.sh create_galaxy_admin "$GALAXY_INSTANCE_URL" "$DEFAULT_GALAXY_ADMIN_EMAIL" "$DEFAULT_GALAXY_ADMIN_STARTING_PW" "$DEFAULT_GALAXY_ADMIN_NAME")
    # Capture the python helper script's exit code
    local exit_code=$?
    # Process any failures
    if [ $exit_code -ne 0 ]; then
        log_error "Failed to create Galaxy admin user with output: $output"
        exit $exit_code
    fi
    log_info "Successfully created Galaxy admin user."
}

# Function to install the tools from our ToolShed into Galaxy using Planemo
install_tools() {
    log_info "Discovering and installing tools from $TOOL_SHED_DIR/ into Galaxy $GALAXY_DIR/..."
    cd "$TOOL_SHED_DIR" || exit
    log_info "Running planemo ci_find_tools to discover tools..."
    tool_files=$(planemo ci_find_tools .)
    for tool_file in $tool_files; do
        tool_dir=$(dirname "$tool_file")
        log_info "Preparing tool in directory $tool_dir..."

        if [ -f "$tool_dir/.shed.yml" ]; then
            log_info "Installing tool from $tool_dir using Galaxy API..."
            python3 install_tool.py "$tool_dir/.shed.yml" "$GALAXY_API_KEY" "$GALAXY_INSTANCE_URL"
        else
            log_error "Missing .shed.yml in $tool_dir"
            shutdown_galaxy_with_error
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
            shutdown_galaxy_with_error
        fi
    done
    log_info "All tools verified successfully."
}

# Function to cleanly shutdown Galaxy
shutdown_galaxy() {
    log_info "Shutting down Galaxy..."
    "$GALAXY_DIR"/run.sh stop
    log_info "Waiting a brief moment for Galaxy to shut down..."
    sleep 2
    if [ -n "$nohup_pid" ]; then
        log_info "Killing run.sh's nohup process group from pid $nohup_pid..."
        kill -TERM -$nohup_pid &> /dev/null # No zombies. No child zombies.
    fi
    sync # Dump any remaining log_info lines from tail to the console
    if [ -n "$tail_pid" ]; then
        log_info "Killing tail's pid $tail_pid..."
        kill $tail_pid &> /dev/null # Seriously. No zombies.
        log_info "Waiting for tail to exit..."
        wait $tail_pid &> /dev/null # The script will outpace tail's ability to shutdown cleanly, so we'll wait on it
    fi
    log_info "Galaxy shutdown complete."
    return 0
}

# Function to do final cleanup and exit with code sent in
exit_installer() {
    trap - ERR # Deregister our trap handler as a best practice
    exit $1
}

# Function to exit with success
shutdown_galaxy_with_success() {
    shutdown_galaxy
    cleanup
    exit_installer 0
}

# Function to exit from error, no cleanup here so the user can look at the logs
shutdown_galaxy_with_error() {
    shutdown_galaxy
    exit_installer 1
}

# Function for handling trapped control signals
trap_handler() {
    log_info "🛑🛑🛑🛑 Caught signal $1. Shutting down now... 🛑🛑🛑🛑"
    shutdown_galaxy_with_error # We're not looking to continue forward to other scripts, so exit 1
}

# Function for any cleanup
cleanup() {
    log_info "Cleaning up..."
    rm -f $GALAXY_INSTALLER_TMP_DIR/install_galaxy.log
}

##############################
######## Script Start ########
##############################

# Intercept ctrl-c and other quit signals to attempt to cleanly stop. Zombie Galaxy is really annoying and easy to end up with.
trap 'trap_handler SIGINT' SIGINT
trap 'trap_handler SIGTERM' SIGTERM 

# Create a place for our logfile
ensure_tmp_directory_exists

# Start Galaxy in the background and populate global pid variables $nohup_pid and $tail_pid
log_info "We're going to try to start Galaxy. This can take a while the first time (~20min), and sometimes it looks stuck for a minute or two when it isn't."
start_galaxy

# Keep checking for Galaxy to become reponsive
check_galaxy

# Create an admin user for Galaxy and capture API key
create_galaxy_admin_user

# Install our tools from our ToolShed repo
log_error "Skipping tool installation until implemented"
# install_tools

# Test a tool from our toolshed
# verify_tools

# Check that Galaxy survived
check_galaxy

log_info "Galaxy setup complete."

# Shutdown Galaxy
shutdown_galaxy_with_success

