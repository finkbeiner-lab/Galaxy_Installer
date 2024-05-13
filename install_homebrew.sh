#!/bin/bash
echo "Checking for Homebrew..."

if command -v brew &>/dev/null; then
    echo "Homebrew is already installed. Checking for updates..."
    brew update
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Verifying Homebrew is working..."
if brew --version &>/dev/null; then
    echo "Homebrew setup complete."
else
    echo "Error: Homebrew installation failed."
    exit 1
fi
