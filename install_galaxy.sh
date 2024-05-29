#!/bin/sh
source "$(dirname "$0")/common.sh"

# Function to clone down the Galaxy repo or pull from the latest release
pull_repo() {
    if [ ! -d "$GALAXY_DIR" ]; then
        log_info "Cloning Galaxy repository..."
        git clone https://github.com/galaxyproject/galaxy.git "$GALAXY_DIR"
    else
        log_info "Galaxy is already installed. Attempting to fast-forward to the latest version..."
        cd "$GALAXY_DIR"
        log_info "Checking out Galaxy's main branch 'dev' for updating..."
        git checkout dev
        if git pull; then
            log_info "Galaxy repository update through fast-forward was successful."
        else
            log_error "Cannot fast-forward. Your copy of Galaxy has diverged significantly from the offical repository. You'll need to resolve a merge manually, or delete $GALAXY_DIR and start fresh."
            popd &> /dev/null
            exit 1
        fi
    fi
}

# Function to get the latest tagged release matching the pattern v00.00.00, this filters out "dev" releases and other random tags
checkout_latest_release() {
    log_info "Finding latest release..."
    git fetch --tags
    latest_tag=$(git tag -l | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)

    if [ -z "$latest_tag" ]; then
        log_error "No valid release tags found. Unsure how to continue."
        popd &> /dev/null
        exit 1
    fi

    # Check out the latest tagged release
    log_info "Checking out latest release version: $latest_tag..."
    if git checkout "$latest_tag"; then
        log_info "Checked out latest release: $latest_tag"
    else
        log_error "Unable to check out the latest release $latest_tag. Unsure how to continue. You'll need to resolve manually or delete $GALAXY_DIR and start fresh."
        popd &> /dev/null
        exit 1
    fi
}

# Function to start Galaxy in the background
start_galaxy() {
    log_info "Starting up Galaxy..."
    # We start Galaxy in a nohup instead of using it's own daemon so we can grab the pid and kill it. Galaxy's own pidfile isn't showing up, and we were getting zombies.
    nohup ./run.sh start &> "$GALAXY_INSTALLER_TMP_DIR/install_galaxy.log" &
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
    exit_install_galaxy_with_error
}


#TODO: This method relies on a ToolShed server being available. We might use Planemo instead...
install_tools_into_galaxy_instance() {
    local api_key="$GALAXY_API_KEY"  # Replace with your Galaxy admin API key

    # Example of installing a tool from the Tool Shed into the Galaxy instance
    local tool_shed_url="https://toolshed.g2.bx.psu.edu"
    local repository_owner="finkbeiner-lab"
    local repository_name="Galaxy_Tool_Shed"

    log_info "Installing tools into Galaxy instance..."

    # Install the repository using Galaxy API
    curl -X POST \
        -H "Content-Type: application/json" \
        -H "x-api-key: $api_key" \
        -d '{
            "tool_shed_url": "'"$tool_shed_url"'",
            "name": "'"$repository_name"'",
            "owner": "'"$repository_owner"'",
            "install_tool_dependencies": true,
            "install_repository_dependencies": true,
            "install_resolver_dependencies": true
        }' \
        "$galaxy_instance_url/api/tool_shed_repositories/install_repositories"

    if [ $? -eq 0 ]; then
        log_info "Tools installed successfully into Galaxy instance."
    else
        log_error "Failed to install tools into Galaxy instance."
        return 1
    fi
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

# Function for handling trapped control signals
trap_handler() {
    log_info "🛑🛑🛑🛑 Caught signal $1. Shutting down now. 🛑🛑🛑🛑"
    shutdown_galaxy                                                                                                                                                                           
    popd &> /dev/null
    exit 0
}

# Function to exit from error
exit_install_galaxy_with_error() {
    log_error "Galaxy server did not start successfully. Take a peak at $GALAXY_INSTALLER_TMP_DIR/install_galaxy.log and $GALAXY_DIR/galaxy.log"
    shutdown_galaxy
    popd &> /dev/null
    exit 1
}

# Function for any cleanup
cleanup() {
    log_info "Cleaning up..."
    rm -f $GALAXY_INSTALLER_TMP_DIR/install_galaxy.log
}

######## Script Start ########
log_info "Starting Galaxy installation..."
log_info "Galaxy will be installed in $GALAXY_DIR"

# Intercept ctrl-c and other quit signals to attempt to cleanly stop. Zombie Galaxy is really annoying and easy to end up with.
# This should be done before continuing on to make any changes that affect the user
trap 'trap_handler SIGINT' SIGINT
trap 'trap_handler SIGTERM' SIGTERM

# Ensure current shell directory does not change for the user unexpectedly
pushd . &> /dev/null

# Navigate to the Galaxy directory
cd "$GALAXY_DIR"

# Pull or fast-forward repo
pull_repo

# Find the latest release tag and then check it out
checkout_latest_release

# Create a place for our logfile
ensure_tmp_directory_exists

# Start Galaxy in the background and populate global pid variables $nohup_pid and $tail_pid
log_info "We're going to try to start Galaxy. This can take a while the first time (~20min), and sometimes it looks stuck for a minute or two when it isn't."
start_galaxy

# Keep checking for Galaxy to become reponsive
check_galaxy

# Install our tools from our ToolShed repo
#install_tools_into_galaxy_instance

# Test a tool from our toolshed
# TODO

# Check that Galaxy survived
check_galaxy

# Shutdown Galaxy
shutdown_galaxy

# Cleanup
cleanup

log_info "Galaxy setup complete."

# Return to the original directory without changing the user's working directory
popd &> /dev/null
exit 0

