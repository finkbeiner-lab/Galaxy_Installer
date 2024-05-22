#! /bin/sh                                                                                                                                         
source common.sh

log_info "Checking for Homebrew..."

if command -v brew &>/dev/null; then
    log_info "Homebrew is already installed. Checking for updates..."
    brew update
else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

log_info "Verifying Homebrew is working..."
if brew --version &>/dev/null; then
    log_info "Homebrew setup complete."
else
    log_error "Homebrew installation failed."
    exit 1
fi

