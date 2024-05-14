#!/bin/zsh

echo "Starting Galaxy installation..."

# Define Galaxy installation directory
galaxy_dir="$HOME/galaxy"

# Ensure current shell directory does not change for the user unexpectedly
pushd .

# Clone or pull the latest Galaxy
if [ ! -d "$galaxy_dir" ]; then
    echo "Cloning Galaxy repository..."
    git clone https://github.com/galaxyproject/galaxy.git "$galaxy_dir"
else
    echo "Galaxy is already installed. Updating to the latest version..."
    cd "$galaxy_dir"
    git pull origin master
fi

# Navigate to the Galaxy directory
cd "$galaxy_dir"

echo "Starting up Galaxy..."
# Start Galaxy in the background
nohup ./run.sh --daemon &> install_galaxy.log &
nohup_pid=$!
tail -f install_galaxy.log &
sleep 5

# Function to check if Galaxy is up by querying the main page
check_galaxy() {
    echo "Checking if Galaxy is up..."
    for i in {1..300}; do  # Check for up to 10 minutes
        echo "Attempting to reach Galaxy server..."
        if curl -s http://localhost:8080 | grep -q 'Galaxy'; then
            return 0
        fi
        sleep 2
    done
    return 1
}

# Function to shutdown Galaxy
shutdown_galaxy() {
    echo "Shutting down Galaxy..."
    ./run.sh --stop-daemon
    sleep 5 # Give Galaxy some time to shut down gracefully
    kill $nohup_pid &> /dev/null # No zombies.
    return 0
}

# Verify Galaxy startup
if check_galaxy; then
    echo "Galaxy setup complete. Server is up and responsive."
else
    echo "☹️ Error: Galaxy server did not start successfully.  Take a peak at $galaxy_dir/install_galaxy.log"
    shutdown_galaxy
    sync # Dump any remaining log lines from tail to the console
    popd
    exit 1
fi

shutdown_galaxy

echo "Cleaning up..."
rm install_galaxy.log

# Return to the original directory without changing the user's working directory
popd
