#!/bin/zsh
source "$(dirname "$0")/common.sh"

log_info "Checking for Miniconda installation..."

if ! command -v conda &> /dev/null; then
    log_info "Miniconda not found. Installing Miniconda..."
    brew install --cask miniconda
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
    conda init zsh
else
    log_info "Miniconda is already installed. Updating Miniconda..."
    conda update -n base -c defaults conda -y
fi

# Pull in install/update changes from miniconda
source ~/.zshrc

# Verify Miniconda installation
log_info "Verifying Miniconda installation..."
if conda --version &>/dev/null; then
    log_info "Miniconda installation was successful."
else
    log_error "Miniconda installation failed."
    exit 1
fi

log_info "Miniconda setup complete."
