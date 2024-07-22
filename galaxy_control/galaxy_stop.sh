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

# Function to stop galaxy
stop_galaxy() {
    source_dependencies
    log_info "Shutting down Galaxy..."
    log_info "Calling Galaxy's run.sh stop..."
    "$GALAXY_DIR"/run.sh stop

    if check_for_pid "$GALAXY_NOHUP_PID"; then
        nohup_pid=$(load_pid "$GALAXY_NOHUP_PID")
        log_info "Killing run.sh's nohup process group from pid $nohup_pid..."
        kill -TERM -$nohup_pid &> /dev/null # No zombies. No child zombies.
        delete_pid_file "$GALAXY_NOHUP_PID"
    fi

    sync # Dump any remaining log_info lines from tail to the console

    if check_for_pid "$TAIL_PID"; then
        tail_pid=$(load_pid "$TAIL_PID")
        log_info "Killing tail's pid $tail_pid..."
        kill $tail_pid &> /dev/null # Seriously. No zombies.
        log_info "Waiting for tail to exit..."
        wait $tail_pid &> /dev/null # The script will outpace tail's ability to shutdown cleanly, so we'll wait on it
        delete_pid_file "$TAIL_PID"
    fi

    log_info "Galaxy shutdown complete."
}

