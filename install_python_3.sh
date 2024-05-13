#!/bin/bash

echo "Checking for Python 3 installation..."

# Install pyenv to manage multiple Python versions
if ! command -v pyenv &> /dev/null; then
    echo "pyenv not found. Installing pyenv..."
    brew install pyenv
else
    echo "pyenv is already installed."
fi

# Initialize pyenv in the current shell session
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Determine the latest Python 3 version
latest_python3_version=$(pyenv install -l | grep -E '^  3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d '[:space:]')

# Install the latest Python 3 version
if pyenv versions | grep -q $latest_python3_version; then
    echo "Python 3 ($latest_python3_version) is already installed. Checking for updates..."
    pyenv install --skip-existing $latest_python3_version
else
    echo "Installing Python 3 ($latest_python3_version)..."
    pyenv install $latest_python3_version
    pyenv global $latest_python3_version
    echo "Python 3 ($latest_python3_version) installed successfully."
fi

# Verify Python installation
if python3 --version &>/dev/null; then
    echo "Verifying Python 3 is working..."
    echo "Python 3 setup complete."
else
    echo "Error: Python 3 installation failed."
    exit 1
fi
