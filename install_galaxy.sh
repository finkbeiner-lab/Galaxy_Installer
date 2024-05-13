#!/bin/zsh

echo "Starting Galaxy installation..."

# Define Galaxy installation directory
galaxy_dir="$HOME/documents/galaxy"

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
./run.sh --daemon &

# Function to check if Galaxy is up by querying the main page
check_galaxy() {
    echo "Checking if Galaxy is up..."
    for i in {1..60}; do  # Check for up to 60 seconds
        if curl -s http://localhost:8080 | grep -q 'Galaxy'; then
            return 0
        fi
        sleep 1
    done
    return 1
}

# Verify Galaxy startup
if check_galaxy; then
    echo "Galaxy setup complete. Server is up and running."
else
    echo "Error: Galaxy server did not start successfully."
    ./run.sh --stop-daemon
    popd
    exit 1
fi

# Optionally stop Galaxy if only testing installation
echo "Shutting down Galaxy..."
./run.sh --stop-daemon

# Return to the original directory without changing the user's working directory
popd
