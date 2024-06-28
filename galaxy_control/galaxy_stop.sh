#!/bin/zsh

# Source the galaxy control plugin to get the project root and other configurations
source "$(dirname "$0")/galaxy_control.plugin.zsh"
source_configs


# We need to embed all of our code in functions (except sourcing) because as a plugin, this file looks to be sourced automatically (and multiple times).


# Function to stop galaxy
stop_galaxy() {
    log_info "Shutting down Galaxy..."
    log_info "Calling Galaxy's run.sh stop..."
    "$GALAXY_DIR"/run.sh stop

    if nohup_pid=$(load_pid "$GALAXY_NOHUP_PID"); then
        log_info "Killing run.sh's nohup process group from pid $nohup_pid..."
        kill -TERM -$nohup_pid &> /dev/null # No zombies. No child zombies.
        delete_pid_file "$GALAXY_NOHUP_PID"
    fi

    sync # Dump any remaining log_info lines from tail to the console

    if tail_pid=$(load_pid "$TAIL_PID"); then
        log_info "Killing tail's pid $tail_pid..."
        kill $tail_pid &> /dev/null # Seriously. No zombies.
        log_info "Waiting for tail to exit..."
        wait $tail_pid &> /dev/null # The script will outpace tail's ability to shutdown cleanly, so we'll wait on it
        delete_pid_file "$TAIL_PID"
    fi

    log_info "Galaxy shutdown complete."
}

