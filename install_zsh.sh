#!/bin/bash

echo -e "${LOG_PREFIX}Checking for Zsh..."

# Check if Zsh is installed and managed by Homebrew
if brew list zsh &>/dev/null; then
    managed_by_brew=true
else
    managed_by_brew=false
fi

# Install Zsh if it is not installed
if ! command -v zsh &>/dev/null; then
    echo -e "${LOG_PREFIX}Installing Zsh..."
    if brew install zsh; then
        echo -e "${LOG_PREFIX}Zsh installed successfully."
    else
        echo -e "${LOG_PREFIX}Error: Zsh installation failed."
        exit 1
    fi
elif [ "$managed_by_brew" = true ]; then
    echo -e "${LOG_PREFIX}Zsh is already installed via Homebrew. Checking for updates..."
    if brew upgrade zsh; then
        echo -e "${LOG_PREFIX}Zsh is up to date."
    else
        echo -e "${LOG_PREFIX}Error: Zsh update failed."
        exit 1
    fi
else
    echo -e "${LOG_PREFIX}Zsh is already installed but not managed by Homebrew."
fi

# Verify Zsh installation
if zsh --version &>/dev/null; then
    echo -e "${LOG_PREFIX}Verifying Zsh is working..."
    echo -e "${LOG_PREFIX}Zsh setup complete."
else
    echo -e "${LOG_PREFIX}Error: Zsh installation verification failed."
    exit 1
fi

# Set Zsh as the default shell if it isn't already
current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
zsh_path=$(which zsh)
if [ "$current_shell" != "$zsh_path" ]; then
    echo -e "${LOG_PREFIX}Your password is required to change your default shell to Zsh. Waiting on user." | tee >(say -v Karen)
    if sudo chsh -s "$zsh_path" "$USER"; then
        echo -e "${LOG_PREFIX}Default shell changed to Zsh."
    else
        echo -e "${LOG_PREFIX}Error: Failed to change default shell to Zsh."
        exit 1
    fi
else
    echo -e "${LOG_PREFIX}Zsh is already the default shell."
fi
