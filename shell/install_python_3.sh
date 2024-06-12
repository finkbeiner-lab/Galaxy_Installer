#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

log_info "Checking for Python 3 installation..."

# Function to check if Conda is installed outside of Miniconda
check_conda_installation() {
    if command -v conda &> /dev/null; then
        if ! conda info --base | grep -q "miniconda"; then
            log_warning "❗❗❗Conda is installed outside of Homebrew managed Miniconda.❗❗❗"
            log_warning "While this might not cause issues today, and we will continue, it prevents this installer from keeping Python, Conda, and Miniconda up-to-date for you."
            log_warning "It is recommended that you uninstall Conda (perhaps by uninstalling Miniconda), and to re-run this installer to manage these for you."
        fi
    fi
}

# Function to install Miniconda if not already installed
install_miniconda() {
    if ! command -v conda &> /dev/null; then
        log_info "conda not found. Installing Miniconda..."
        brew install --cask miniconda
    else
        log_info "conda is already installed."
    fi
    conda init "$(basename "${SHELL}")"
}

# Function to ensure Python is installed and updated within Miniconda's provided versions
ensure_python_installed() {
    local python_version=$1
    if ! conda list | grep -q "python\s*$python_version"; then
        log_info "Installing Python $python_version using conda..."
        conda install python=$python_version -y
    else
        log_info "Python $python_version is already installed."
    fi
}

# Function to verify that Python 3 is correctly installed
verify_python_installation() {
    log_info "Verifying Python 3 is working..."
    if python3 --version &>/dev/null; then
        log_info "Python 3 installation was successful."
    else
        log_error "Python 3 installation failed."
        exit 1
    fi
}

###############################
######## Script Start ########
##############################

# Check if Conda is managed outside of Miniconda installed by Homebrew
check_conda_installation

# Install or update Miniconda
install_miniconda

# Determine the latest Python version provided by Miniconda
latest_python_version=$(conda search python | grep -Eo '3\.[0-9]+\.[0-9]+' | sort -V | tail -1)
log_info "Latest Python version available in Miniconda: $latest_python_version"

# Grab latest python that Conda supports
ensure_python_installed $latest_python_version

# Verify that we can call into python3
verify_python_installation

log_info "Python 3 setup complete."
