#! /bin/sh
source common.sh

log_info "Installing Galaxy and its dependencies on macOS..."

# Ensure each script is executable
chmod +x \
install_xcode_tools.sh \
install_homebrew.sh \
install_zsh.sh \
install_oh-my-zsh.sh \
install_python_3.sh \
install_galaxy.sh \
install_tool_shed.sh

# Function to run a script and check its exit status
run_script() {
    ./$1
    if [ $? -ne 0 ]; then
        log_error "$1 failed."
        exit 1
    fi
}

# Run each script and check for success
run_script install_xcode_tools.sh
run_script install_homebrew.sh
run_script install_zsh.sh
run_script install_oh-my-zsh.sh
run_script install_python_3.sh
run_script install_galaxy.sh
run_script install_tool_shed.sh

log_info "Setup completed successfully."
