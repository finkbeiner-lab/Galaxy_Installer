#!/bin/bash

echo "Checking for Zsh..."

# Install Zsh if it is not installed
if ! command -v zsh &>/dev/null; then
    echo "Installing Zsh..."
    brew install zsh
    if [ $? -ne 0 ]; then
        echo "Error: Zsh installation failed."
        exit 1
    fi
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
    echo "Error: Zsh installation verification failed."
    exit 1
fi

# Set Zsh as the default shell if it isn't already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting Zsh as the default shell..."
    if sudo chsh -s $(which zsh) $USER; then
        echo "Default shell changed to Zsh."
    else
        echo "Error: Failed to change default shell to Zsh. This is probably okay, on newer versions of macOS zsh is already the default shell."
    fi
fi
