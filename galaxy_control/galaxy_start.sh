#!/bin/zsh

# Use the  galaxy control plugin to get the project root and other configurations
source "$(dirname "$0")/galaxy_control.plugin.zsh"
source_configs


# We need to embed all of our code in functions (except sourcing) because as a plugin, this file looks to be sourced automatically (and multiple times).


# Function to start galaxy
start_galaxy() {
    log_info "Starting up Galaxy..."
    # We start Galaxy in a nohup instead of using its own daemon so we can grab the pid and kill it. Galaxy's own pidfile isn't showing up, and we were getting zombies.
    # We redirect the output to a log, but also redirect the input or else it will suspend the nohup after this script exits.
    nohup "$GALAXY_DIR"/run.sh start &> "$GALAXY_LOG_FILE" < /dev/null &
    nohup_pid=$!
    create_pid_file $nohup_pid "$GALAXY_NOHUP_PID"
    log_info "Captured run.sh's nohup pid as $nohup_pid"

    tail -F "$GALAXY_LOG_FILE" &
    tail_pid=$!
    create_pid_file $tail_pid "$TAIL_PID"
    log_info "Captured tail's pid as $tail_pid"
}

