#!/bin/bash
echo -e "${LOG_PREFIX}Checking for Homebrew..."

if command -v brew &>/dev/null; then
    echo -e "${LOG_PREFIX}Homebrew is already installed. Checking for updates..."
    brew update
else
    echo -e "${LOG_PREFIX}Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo -e "${LOG_PREFIX}Verifying Homebrew is working..."
if brew --version &>/dev/null; then
    echo -e "${LOG_PREFIX}Homebrew setup complete."
else
    echo -e "${LOG_PREFIX}Error: Homebrew installation failed."
    exit 1
fi
