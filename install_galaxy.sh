#!/bin/zsh

echo "Starting Galaxy installation..."

# Define Galaxy installation directory
galaxy_dir="$HOME/gladstone/finkbeinerlab/galaxy"
echo "Galaxy will be installed in $galaxy_dir"

# Ensure current shell directory does not change for the user unexpectedly
pushd .

# Clone or pull the latest Galaxy
if [ ! -d "$galaxy_dir" ]; then
    echo "Cloning Galaxy repository..."
    git clone https://github.com/galaxyproject/galaxy.git "$galaxy_dir"
else
    echo "Galaxy is already installed. Attempting to fast-forward to the latest version..."
    cd "$galaxy_dir"
    git fetch origin
    if git merge --ff-only origin/master; then
        echo "Fast-forward successful."
    else
        echo "Cannot fast-forward. Your copy of Galaxy has diverged significantly from the offical repository. You'll need to resolve a merge manually, or delete $galaxy_dir and start fresh."
        popd
        exit 1
    fi
fi

# Navigate to the Galaxy directory
cd "$galaxy_dir"

echo "Starting up Galaxy..."
# Start Galaxy in the background
nohup ./run.sh --daemon &> install_galaxy.log &
nohup_pid=$!
tail -F install_galaxy.log &
tail_pid=$!
sleep 5

# Function to check if Galaxy is up by querying the main page
check_galaxy() {
    echo "Checking if Galaxy is up..."
    for i in {1..600}; do  # Check for up to 30 minutes
        echo "Waiting for Galaxy server to spin up... $i/600."
        if curl -s http://localhost:8080 | grep -q 'Galaxy'; then
            return 0
        fi
        sleep 3
    done
    return 1
}

# Function to shutdown Galaxy
shutdown_galaxy() {
    echo "Shutting down Galaxy..."
    ./run.sh --stop-daemon
    sleep 5 # Give Galaxy some time to shut down gracefully
    kill $nohup_pid &> /dev/null # No zombies.
    sync # Dump any remaining log lines from tail to the console
    kill $tail_pid
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
    echo "Galaxy setup complete. Server is up and responsive."
else
    echo "☹️ Error: Galaxy server did not start successfully.  Take a peak at $galaxy_dir/install_galaxy.log"
    exit_install_galaxy
fi

shutdown_galaxy

echo "Cleaning up..."
rm install_galaxy.log

# Return to the original directory without changing the user's working directory
popd
