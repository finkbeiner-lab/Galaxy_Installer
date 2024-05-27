#!/bin/zsh
source "$(dirname "$0")/common.sh"

log_info "Checking for Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My Zsh is already installed. Checking for updates..."
    pushd "$HOME/.oh-my-zsh" > /dev/null  # Save and change directory
    git pull
    popd > /dev/null  # Restore original directory
else
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

log_info "Verifying Oh My Zsh is working..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My Zsh setup complete."
else
    log_error "Oh My Zsh installation failed."
    popd
    exit 1
fi

