#!/bin/bash

echo "Checking for Zsh..."

# Check if Zsh is installed and managed by Homebrew
if brew list zsh &>/dev/null; then
    managed_by_brew=true
else
    managed_by_brew=false
fi

# Install Zsh if it is not installed
if ! command -v zsh &>/dev/null; then
    echo "Installing Zsh..."
    if brew install zsh; then
        echo "Zsh installed successfully."
    else
        echo "Error: Zsh installation failed."
        exit 1
    fi
elif [ "$managed_by_brew" = true ]; then
    echo "Zsh is already installed via Homebrew. Checking for updates..."
    if brew upgrade zsh; then
        echo "Zsh is up to date."
    else
        echo "Error: Zsh update failed."
        exit 1
    fi
else
    echo "Zsh is already installed but not managed by Homebrew."
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
current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
zsh_path=$(which zsh)
if [ "$current_shell" != "$zsh_path" ]; then
    echo "Your password is required to change your default shell to Zsh. Waiting on user." | tee >(say -v Karen)
    if sudo chsh -s "$zsh_path" "$USER"; then
        echo "Default shell changed to Zsh."
    else
        echo "Error: Failed to change default shell to Zsh."
        exit 1
    fi
else
    echo "Zsh is already the default shell."
fi
