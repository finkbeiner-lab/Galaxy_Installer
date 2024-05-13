#!/bin/bash
echo "Checking for Zsh..."

# Install Zsh if it is not installed
if ! command -v zsh &>/dev/null; then
    echo "Installing Zsh..."
    brew install zsh
    echo "Zsh installed successfully."
else
    echo "Zsh is already installed. Checking for updates..."
    brew upgrade zsh
fi

# Verify Zsh installation
if zsh --version &>/dev/null; then
    echo "Verifying Zsh is working..."
    echo "Zsh setup complete."
else
    echo "Error: Zsh installation failed."
    exit 1
fi

# Set Zsh as the default shell if it isn't already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting Zsh as the default shell..."
    chsh -s $(which zsh)
    echo "Default shell changed to Zsh."
fi

