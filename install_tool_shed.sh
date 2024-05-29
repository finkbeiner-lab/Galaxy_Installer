#!/bin/zsh
source "$(dirname "$0")/common.sh"

# Function to check if Planemo is installed
check_planemo() {
    log_info "Checking if Planemo is installed..."
    command -v planemo &>/dev/null
}

# Function to install Planemo, a tool for creating and testing new tools for the ToolShed
# We might not need this in remote instances of Galaxy, and perhaps not the pipx dependency, but this script doesn't detect different environments yet
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

# Function to download our ToolShed
get_tool_shed_repo() {
    if [ ! -d "$TOOL_SHED_DIR" ]; then
        log_info "Cloning the $TOOL_SHED_NAME ToolShed repository into $TOOL_SHED_DIR..."
        git clone "$TOOL_SHED_REPO" "$TOOL_SHED_DIR"
    else
        log_info "Updating the $TOOL_SHED_NAME ToolShed repository..."
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
log_info "Getting the $TOOL_SHED_NAME ToolShed and its dependencies ($TOOL_SHED_REPO)...."

# Get Planemo
install_or_update_planemo

# Download or update our ToolShed
get_tool_shed_repo

log_info "$TOOL_SHED_NAME ToolShed now available with dependencies installed and up-to-date.."

