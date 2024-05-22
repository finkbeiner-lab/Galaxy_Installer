#!/bin/zsh
source common.sh

# Check if pipx is installed
check_pipx() {
    log_info "Checking if pipx is installed..."
    command -v pipx &>/dev/null
}

# Install pipx
install_pipx() {
    log_info "Installing pipx..."
    brew install pipx
    if brew list pipx &>/dev/null; then
        pipx ensurepath
        source ~/.zshrc
        log_info "pipx installed and PATH updated."
    else
        log_error "Failed to install pipx."
        exit 1
    fi
}

# Check if Planemo is installed
check_planemo() {
    log_info "Checking if Planemo is installed..."
    command -v planemo &>/dev/null
}

# Install Planemo
install_planemo() {
    log_info "Installing Planemo..."
    pipx install planemo
    if command -v planemo &>/dev/null; then
        log_info "Planemo installed."
    else
        log_error "Failed to install Planemo."
        exit 1
    fi
}

# Main script execution
log_info "Installing the Finkbiener Tool Shed into Galaxy (https://github.com/finkbeiner-lab/Galaxy_Tool_Shed)...."

# Install pipx if not installed
if check_pipx; then
    log_info "pipx is already installed."
else
    install_pipx
fi

# Install Planemo if not installed
if check_planemo; then
    log_info "Planemo is already installed."
else
    install_planemo
fi

log_info "Finkbiener Tool Shed installation successful."
