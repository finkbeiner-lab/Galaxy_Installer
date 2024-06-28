#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh" 

# Function to check if Planemo is installed
check_planemo() {
    log_info "Checking if Planemo is installed..."
    command -v planemo &>/dev/null
}

# Function to install Planemo, a tool for creating and testing new tools for the Tool Shed
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
    log_info "Grabbing our tool shed (deep clone)..."
    if [ ! -d "$TOOL_SHED_DIR" ]; then
        log_info "Cloning the $TOOL_SHED_NAME repository into $TOOL_SHED_DIR..."
        git clone "$TOOL_SHED_REPO" "$TOOL_SHED_DIR"
    else
        log_info "Tool shed exists, updating the $TOOL_SHED_NAME repository..."
        if git -C "$TOOL_SHED_DIR" pull --ff-only; then
            log_info "Tool shed repository update through fast-forward was successful."
        else
            log_error "Cannot fast-forward. Your copy of the tool shed has diverged significantly from the repository. You can resolve a merge manually if this is intentional, or delete $TOOL_SHED_DIR and re-run this installer."
            exit 1
        fi
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
log_info "Getting the $TOOL_SHED_NAME and tool shed utilities ($TOOL_SHED_REPO)...."

# Get Planemo
install_or_update_planemo

# Download or update our ToolShed
get_tool_shed_repo

log_info "$TOOL_SHED_NAME and related utilities successfully installed."

