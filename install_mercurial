#!/bin/zsh

echo "Checking for Mercurial (hg)..."

# Function to verify Mercurial installation
verify_mercurial() {
    if hg --version &>/dev/null; then
        echo "Verifying Mercurial is working..."
        tmp_dir=$(mktemp -d -t hgtest-XXXXXXXXXX)
        if hg init "$tmp_dir/test_repo" &>/dev/null; then
            echo "Mercurial setup complete."
            rm -rf "$tmp_dir"
        else
            echo "Error: Mercurial verification failed."
            rm -rf "$tmp_dir"
            exit 1
        fi
    else
        echo "Error: Mercurial installation failed."
        exit 1
    fi
}

# Check if Mercurial is installed
if ! command -v hg &>/dev/null; then
    echo "Installing Mercurial..."
    brew install mercurial
    echo "Mercurial installed successfully."
else
    echo "Mercurial is already installed. Checking for updates..."
    brew upgrade mercurial
fi

# Verify Mercurial installation
verify_mercurial
