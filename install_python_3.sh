#!/bin/zsh
source common.sh

log_info "Checking for Python 3 installation..."

# Install pyenv to manage multiple Python versions
if ! command -v pyenv &> /dev/null; then
    log_info "pyenv not found. Installing pyenv..."
    brew install pyenv
else
    log_info "pyenv is already installed."
fi

# Initialize pyenv in the current shell session
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Determine the latest Python 3 version
latest_python3_version=$(pyenv install -l | grep -E '^  3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d '[:space:]')

# Install the latest Python 3 version
if pyenv versions | grep -q $latest_python3_version; then
    log_info "Python 3 ($latest_python3_version) is already installed. Checking for updates..."
    pyenv install --skip-existing $latest_python3_version
else
    log_info "Installing Python 3 ($latest_python3_version)..."
    pyenv install $latest_python3_version
    pyenv global $latest_python3_version
    log_info "Python 3 ($latest_python3_version) installed successfully."
fi

# Verify Python installation
if python3 --version &>/dev/null; then
    log_info "Verifying Python 3 is working..."
    log_info "Python 3 setup complete."
else
    log_error "Python 3 installation failed."
    exit 1
fi

