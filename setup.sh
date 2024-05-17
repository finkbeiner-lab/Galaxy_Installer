#!/bin/bash
echo -e "${LOG_PREFIX}Installing Galaxy and its dependencies on macOS..."

# Define a logging prefix with an emoji and colored text
export LOG_PREFIX="\033[1;34m🔬 [INSTALL GALAXY PROJECT]\033[0m "


# Ensure each script is executable
chmod +x \
install_xcode_tools.sh \
install_homebrew.sh \
install_zsh.sh \
install_oh-my-zsh.sh \
install_python_3.sh \
configure_git.sh \
install_galaxy.sh \
install_tool_shed.sh

# Function to run a script and check its exit status
run_script() {
    ./$1
    if [ $? -ne 0 ]; then
        echo -e "${LOG_PREFIX}Error: $1 failed."
        exit 1
    fi
}

# Run each script and check for success
run_script install_xcode_tools.sh
run_script install_homebrew.sh
run_script install_zsh.sh
run_script install_oh-my-zsh.sh
run_script install_python_3.sh
run_script configure_git.sh
run_script install_galaxy.sh
run_script install_tool_shed.sh

echo -e "${LOG_PREFIX}Setup completed successfully."
