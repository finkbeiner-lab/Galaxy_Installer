#!/bin/bash
echo "Checking for Python 3..."

if brew list python &>/dev/null; then
    echo "Python 3 is already installed. Checking for updates..."
    brew upgrade python
else
    echo "Installing Python 3..."
    brew install python
fi

echo "Verifying Python 3 is working..."
if python3 --version &>/dev/null; then
    echo "Python 3 setup complete."
else
    echo "Error: Python 3 installation failed."
    exit 1
fi

echo "Checking PATH for Python 3..."
if [[ ":$PATH:" != *":/usr/local/opt/python/libexec/bin:"* ]]; then
    echo "Configuring PATH for Python 3..."
    echo 'export PATH="/usr/local/opt/python/libexec/bin:$PATH"' >> ~/.zshrc
    export PATH="/usr/local/opt/python/libexec/bin:$PATH"
fi

echo "Verifying PATH configuration..."
if [[ ":$PATH:" == *":/usr/local/opt/python/libexec/bin:"* ]]; then
    echo "PATH configuration verified successfully."
else
    echo "Error: PATH configuration failed."
    exit 1
fi
