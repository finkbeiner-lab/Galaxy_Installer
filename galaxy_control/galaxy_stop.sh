#!/bin/zsh
# galaxy_stop.sh

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

# Function to kill processes
kill_process() {
    pid_name=$1
    if check_for_pid "$pid_name"; then
        pid_number=$(load_pid "$pid_name")
        log_info "Killing $pid_name from pid $pid_number..."
        kill -TERM $pid_number &> /dev/null
        delete_pid_file "$pid_name"
    fi
}

# Function to stop galaxy
stop_galaxy() {
    source_dependencies
    log_info "Shutting down Galaxy..."
    log_info "Calling Galaxy's run.sh stop..."
    "$GALAXY_DIR"/run.sh stop
    sleep 0.5
    kill_process "$GALAXY_NOHUP_PID"
    sync # Dump any remaining log_info lines from tail to the console
    kill_process "$TAIL_PID"
    log_info "Galaxy shutdown complete."
}

