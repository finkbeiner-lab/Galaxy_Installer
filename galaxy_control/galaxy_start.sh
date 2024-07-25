#!/bin/zsh

# We need to embed all of our code in functions because as a plugin, this file looks to be sourced automatically (and multiple times).

SCRIPT_PATH="__SCRIPT_PATH__"
PROJECT_ROOT="__PROJECT_ROOT__"

# Function to source required configuration files
source_configs() {
    source "$PROJECT_ROOT/config.sh"
    source "$PROJECT_ROOT/common.sh"
}

# Function to source configurations, paths, and common functions
source_dependencies() {
    # Source the main plugin file with common functions
    source "$SCRIPT_PATH"
    source_configs
}

# Function to check if an existing Galaxy instance is running, and kill it
kill_any_running_galaxy_instances() {
    log_info "Looking for existing Galaxy instances..."
    if check_for_pid "$GALAXY_NOHUP_PID"; then
        GALAXY_PID=$(load_pid "$GALAXY_NOHUP_PID")
        log_info "Galaxy pid found in pidfile ($GALAXY_PID)..."
        log_info "Executing Highlander Protocol. There can only be one."
        # Run the galaxy_stop.sh shutdown script
        galaxy stop
    else
        log_info "No Galaxy instances mangaged by this project found. Proceed with launch..."
    fi
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
    log_error "Galaxy server did not start successfully. Take a peek at $GALAXY_INSTALLER_TMP_DIR/install_galaxy.log and $GALAXY_DIR/galaxy.log"
}

# Function to start galaxy and main entry point for this script
start_galaxy() {
    source_dependencies
    kill_any_running_galaxy_instances
    log_info "Starting up Galaxy..."
    # We start Galaxy in a nohup instead of using its own daemon so we can grab the pid and kill it. Galaxy's own pidfile isn't showing up, and we were getting zombies.
    # We redirect the output to a log, but also redirect the input to /dev/null  or else it will suspend the nohup after this script exits.
    if [ -z "$GALAXY_DIR" ]; then
        log_error "GALAXY_DIR varaible wasn't resolved to a value. $0 needs to be debugged for config loading issues."
        return 1
    fi
    if [ -z "$GALAXY_LOG_FILE" ]; then
        log_error "GALAXY_LOG_FILE varaible wasn't resolved to a value. $0 needs to be debugged for config loading issues."
        return 1
    fi
    nohup "$GALAXY_DIR"/run.sh start &> "$GALAXY_LOG_FILE" < /dev/null &
    nohup_pid=$!
    create_pid_file $nohup_pid "$GALAXY_NOHUP_PID"
    log_info "Captured run.sh's nohup pid as $nohup_pid"
    tail -F "$GALAXY_LOG_FILE" &
    tail_pid=$!
    create_pid_file $tail_pid "$TAIL_PID"
    log_info "Captured tail's pid as $tail_pid"
    wait $nohup_pid
    check_galaxy
}

