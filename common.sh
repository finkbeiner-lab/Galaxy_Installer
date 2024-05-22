#! /bin/sh
# Provides a common set of utilities for the other scripts

# Function to log informational messages
log_info() {
    echo "\033[0;34m🔬 [INSTALL GALAXY PROJECT] $1\033[0m"  # Blue
}

# Function to log error messages
log_error() {
    echo "\033[0;31m🔬 [ERROR] $1\033[0m" >&2  # Red, to stderr
}


