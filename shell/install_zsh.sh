#!/bin/sh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# Function to check if Zsh is installed and manage updates
install_and_update_zsh() {
    if command -v zsh &>/dev/null; then
        log_info "Zsh is already installed."
        if brew list zsh &>/dev/null; then
            log_info "Zsh is installed via Homebrew. Checking for updates..."
            if ! brew upgrade zsh; then
                log_error "Zsh update failed."
                exit 1
            fi
            log_info "Zsh is up to date."
        else
            log_info "Zsh is not managed by Homebrew. Will not attempt update..."
        fi
    else
        log_info "Zsh is not installed. Installing Zsh..."
        if ! brew install zsh; then
            log_error "Zsh installation failed."
            exit 1
        fi
        log_info "Zsh installed successfully."
        verify_zsh_installation
    fi
}

# Function to verify Zsh installation
verify_zsh_installation() {
    if ! zsh --version &>/dev/null; then
        log_error "Zsh installation verification failed."
        exit 1
    fi
    log_info "Zsh setup complete."
}

# Function to set Zsh as the default shell
set_default_shell() {
    if [ -z "$CI" ]; then  # Skip if in a CI environment
        local current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
        local zsh_path=$(which zsh)
        if [ "$current_shell" != "$zsh_path" ]; then
            log_info "Your password may be required to change your default shell to Zsh."
            if ! sudo chsh -s "$zsh_path" "$USER"; then
                log_error "Failed to change default shell to Zsh."
                exit 1
            fi
            log_info "Default shell changed to Zsh."
        else
            log_info "Zsh is already the default shell."
        fi
    else
        log_info "Skipping changing the default shell in automated runner."
    fi
}

##############################
######## Script Start ########
##############################

install_and_update_zsh
verify_zsh_installation
set_default_shell

