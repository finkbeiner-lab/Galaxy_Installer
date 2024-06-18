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
        log_info "Conda is already installed."
    fi
    conda init "$(basename "${SHELL}")"
}

# Function to find the latest version of Python 3 packaged with Conda
find_latest_conda_python_version() {
    log_info "Asking Conda what the latest Python 3 version it currently supports is..."
    latest_python_version=$(conda search 'python>=3' | tail -n 1 | grep -Eo '3\.[0-9]+\.[0-9]+')
    if [ -n "$latest_python_version" ]; then
        log_info "Found latest version of Python 3 in Conda: $latest_python_version"
        echo "$latest_python_version"
    else
        log_error "Unable to find the latest version of python supported by Conda."
        exit 1
    fi
}

# Function to ensure Python is installed and updated within Miniconda's provided versions
install_latest_python() {
    latest_python_version=$(conda search 'python>=3' | tail -n 1 | grep -Eo '3\.[0-9]+\.[0-9]+')
    if [ -z "$latest_python_version" ]; then 
        log_error "Unable to resolve latest Python version from Conda."
        exit 1
    fi
    if ! conda list | grep -Eq "^python[[:space:]]+${latest_python_version}"; then
        log_info "Installing Python $latest_python_version using conda..."
        conda install python=$latest_python_version -y
    else
        log_info "Python $latest_python_version is already installed."
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

# Grab latest python that Conda supports
install_latest_python

# Verify that we can call into python3
verify_python_installation

log_info "Python 3 setup complete."

