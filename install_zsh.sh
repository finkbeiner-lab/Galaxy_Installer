#! /bin/sh                                                                                                                                         
source common.sh

log_info "Checking for Zsh..."

# Check if Zsh is installed and managed by Homebrew
if brew list zsh &>/dev/null; then
    managed_by_brew=true
else
    managed_by_brew=false
fi

# Install Zsh if it is not installed
if ! command -v zsh &>/dev/null; then
    log_info "Installing Zsh..."
    if brew install zsh; then
        log_info "Zsh installed successfully."
    else
        log_error "Zsh installation failed."
        exit 1
    fi
elif [ "$managed_by_brew" = true ]; then
    log_info "Zsh is already installed via Homebrew. Checking for updates..."
    if brew upgrade zsh; then
        log_info "Zsh is up to date."
    else
        log_error "Zsh update failed."
        exit 1
    fi
else
    log_info "Zsh is already installed but not managed by Homebrew."
fi

# Verify Zsh installation
if zsh --version &>/dev/null; then
    log_info "Verifying Zsh is working..."
    log_info "Zsh setup complete."
else
    log_error "Zsh installation verification failed."
    exit 1
fi

# Set Zsh as the default shell if it isn't already
current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
zsh_path=$(which zsh)
if [ "$current_shell" != "$zsh_path" ]; then
    log_info "Your password is required to change your default shell to Zsh. Waiting on user..."
    play_alert_sound
    if sudo chsh -s "$zsh_path" "$USER"; then
        log_info "Default shell changed to Zsh."
    else
        log_error "Failed to change default shell to Zsh."
        exit 1
    fi
else
    log_info "Zsh is already the default shell."
fi

