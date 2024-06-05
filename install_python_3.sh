#!/bin/zsh
source "$(dirname "$0")/common.sh"

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
log_info "Verifying Python 3 is working..."
if python3 --version &>/dev/null; then
    log_info "Python 3 installation was successful."
else
    log_error "Python 3 installation failed."
    exit 1
fi

# Install pipx to allow us to install stand-alone python utilities and have them available across all version of python
log_info "Installing pipx..."
brew install pipx
if brew list pipx &>/dev/null; then
    pipx ensurepath &> /dev/null # pipx outputs this scary looking warning every time, so we're going to sadly swallow this output
    source ~/.zshrc
    log_info "pipx installed and PATH updated."
else
    log_error "Failed to install pipx."
    exit 1
fi

# Install Miniconda
log_info "Checking for Miniconda installation..."
if ! command -v conda &> /dev/null; then
    log_info "Miniconda not found. Installing Miniconda..."
    brew install --cask miniconda
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
    conda init zsh
else
    log_info "Miniconda is already installed. Updating Miniconda..."
    conda update -n base -c defaults conda
fi

# Pull in install/update changes from miniconda
source ~/.zshrc

# Verify Miniconda installation
log_info "Verifying Miniconda installation..."
if conda --version &>/dev/null; then
    log_info "Miniconda installation was successful."
else
    log_error "Miniconda installation failed."
    exit 1
fi

log_info "Python 3 setup complete."

