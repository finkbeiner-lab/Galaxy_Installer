#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"  

log_info "Installing pipx..."

# Install pipx to allow us to install stand-alone python utilities and have them available across all version of python
brew install pipx
if brew list pipx &>/dev/null; then
    pipx ensurepath &> /dev/null # pipx outputs this scary looking warning every time, so we're going to sadly swallow this output
    source ~/.zshrc
    log_info "pipx installed and PATH updated."
else
    log_error "Failed to install pipx."
    exit 1
fi

log_info "pipx setup complete."
