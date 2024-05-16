#!/bin/bash
echo -e "${LOG_PREFIX}Checking for Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${LOG_PREFIX}Oh My Zsh is already installed. Checking for updates..."
    pushd "$HOME/.oh-my-zsh" > /dev/null  # Save and change directory
    git pull
    popd > /dev/null  # Restore original directory
else
    echo -e "${LOG_PREFIX}Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo -e "${LOG_PREFIX}Verifying Oh My Zsh is working..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${LOG_PREFIX}Oh My Zsh setup complete."
else
    echo -e "${LOG_PREFIX}Error: Oh My Zsh installation failed."
    popd
    exit 1
fi
