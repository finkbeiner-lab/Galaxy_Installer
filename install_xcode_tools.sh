#! /bin/sh                                                                                                                                         
source common.sh

log_info "Checking for Xcode Command Line Tools..."

if xcode-select -p &>/dev/null; then
    log_info "Xcode Command Line Tools are already installed. Checking for updates..."
    # Xcode CLT updates are typically handled through the Mac App Store, so this might be a manual update check.
else
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
fi

log_info "Verifying Xcode Command Line Tools are working..."
# Verification could be simply checking the installation path again or trying a command.
if xcode-select -p &>/dev/null; then
    log_info "Xcode Command Line Tools setup complete."
else
    log_error "Xcode Command Line Tools installation failed."
    exit 1
fi

