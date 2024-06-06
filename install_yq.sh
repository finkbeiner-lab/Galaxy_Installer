#!/bin/zsh
source "$(dirname "$0")/common.sh"

log_info "Checking for yq..."

# Check if yq is installed
if command -v yq &> /dev/null; then
    log_info "yq is already installed. Checking for updates..."
    brew upgrade yq
else
    log_info "Installing yq..."
    brew install yq
fi

log_info "Verifying yq installation..."
if command -v yq &> /dev/null; then
    log_info "yq setup complete."
else
    log_error "yq installation failed."
    exit 1
fi
