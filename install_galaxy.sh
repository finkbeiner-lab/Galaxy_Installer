#!/bin/sh
source common.sh

log_info "Starting Galaxy installation..."

# Define Galaxy installation directory... NOTE! This has to be somewhat short or Galaxy will fail to start supervisord !!
galaxy_dir="$HOME/galaxy"
log_info "Galaxy will be installed in $galaxy_dir"

# Ensure current shell directory does not change for the user unexpectedly
pushd .

# Clone or pull the latest Galaxy
if [ ! -d "$galaxy_dir" ]; then
    log_info "Cloning Galaxy repository..."
    git clone https://github.com/galaxyproject/galaxy.git "$galaxy_dir"
else
    log_info "Galaxy is already installed. Attempting to fast-forward to the latest version..."
    cd "$galaxy_dir"
    echo "${LOG_PREFIX}Checking out Galaxy's main branch 'dev' for updating..."
    git checkout dev
    if git pull; then
        log_info "Galaxy repository update through fast-forward was successful."
    else
        log_error "Cannot fast-forward. Your copy of Galaxy has diverged significantly from the offical repository. You'll need to resolve a merge manually, or delete $galaxy_dir and start fresh."
        popd &> /dev/null
        exit 1
    fi
fi

# Navigate to the Galaxy directory
cd "$galaxy_dir"

# Get the latest tagged release matching the pattern vXXXX.XXXX.XXXX, this filters out "dev" releases and other random tags
log_info "Finding latest release..."
git fetch --tags
latest_tag=$(git tag -l | grep '^v[0-9]\+\.[0-9]\+\.[0-9]\+$' | sort -V | tail -n 1)

# Check out the latest tagged release
log_info "Checking out latest release..."
if git checkout "$latest_tag"; then
    log_info "Checked out latest release: $latest_tag"
else
    log_error "Unable to check out the latest release. Unsure how to continue. You'll need to resolve manually or delete $galaxy_dir and start fresh."
    popd
    exit 1
fi

log_info "Starting up Galaxy..."
# Start Galaxy in the background
nohup ./run.sh start &> install_galaxy.log &
nohup_pid=$!
tail -F install_galaxy.log &
tail_pid=$!
sleep 5

# Function to check if Galaxy is up by querying the main page
check_galaxy() {
    log_info "Waiting for Galaxy server to spin up. This can take a good while the first time (~20min), and sometimes it looks stuck for a minute or two when it isn't."
    for i in {1..600}; do  # Check for up to 30 minutes
        log_info "Waiting for Galaxy server to spin up... $i/600"
        if curl -s http://localhost:8080 | grep -q 'Galaxy'; then
            return 0
        fi
        sleep 3
    done
    return 1
}

# Function to shutdown Galaxy
shutdown_galaxy() {
    log_info "Shutting down Galaxy..."
    ./run.sh stop
    sleep 5 # Give Galaxy some time to shut down gracefully
    kill $nohup_pid &> /dev/null # No zombies.
    sync # Dump any remaining log_info lines from tail to the console
    kill $tail_pid &> /dev/null # Seriously. No zombies.
    log_info "Waiting for tail to exit..."
    wait $tail_pid &> /dev/null
    return 0
}

# Function to exit from error
exit_install_galaxy() {
    shutdown_galaxy
    popd
    exit 1
}

# Intercept ctrl-c (SIGINT)
trap exit_install_galaxy SIGINT

# Verify Galaxy startup
if check_galaxy; then
    log_info "Galaxy setup complete. Server is up and responsive."
else
    log_error "Galaxy server did not start successfully.  Take a peak at $galaxy_dir/install_galaxy.log and $galaxy_dir/galaxy.log"
    exit_install_galaxy
fi

shutdown_galaxy

log_info "Cleaning up..."
rm install_galaxy.log

# Return to the original directory without changing the user's working directory
popd &> /dev/null

