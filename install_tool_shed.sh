#!/bin/zsh
source "$(dirname "$0")/common.sh"

# Function to check if Planemo is installed
check_planemo() {
    log_info "Checking if Planemo is installed..."
    command -v planemo &>/dev/null
}

# Function to install Planemo
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

# Function to download the Finkbeiner ToolShed
# NOTE! The Finkbeiner ToolShed is currently a public repository.
# This is mostly do to the complexity of managing public/private key pairs automatically without messing up what folks might have already set up.
# I took a stab at it, and it doesn't appear intractable, just challenging. In the future, we should probably give it a shot so we can make our ToolShed private.
get_tool_shed_repo() {
    if [ ! -d "$TOOL_SHED_DIR" ]; then
        log_info "Cloning the Finkbeiner ToolShed repository into $TOOL_SHED_DIR..."
        git clone https://github.com/finkbeiner-lab/Galaxy_Tool_Shed.git "$TOOL_SHED_DIR"
    else
        log_info "Updating the Finkbeiner Tool Shed repository..."
        cd "$TOOL_SHED_DIR" && git pull
    fi
}

# Function to install or update Planemo
install_or_update_planemo() {
    if check_planemo; then
        log_info "Planemo is already installed."
        log_info "Updating Planemo..."
        if pipx upgrade planemo; then
            log_info "Planemo up-to-date."
        else
            log_error "Failed to update Planemo."
        fi
    else
        install_planemo
    fi
}

######## Script Start ########
log_info "Getting the Finkbiener ToolShed and its dependencies (https://github.com/finkbeiner-lab/Galaxy_Tool_Shed)...."

# Get Planemo
install_or_update_planemo

# Download or update our ToolShed
get_tool_shed_repo

log_info "Finkbiener ToolShed now available with dependencies installed and up-to-date.."

