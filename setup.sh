#!/bin/bash
echo "Starting main setup process..."

# Ensure each script is executable
chmod +x install_xcode_tools.sh install_homebrew.sh install_zsh.sh install_oh-my-zsh.sh install_python_3.sh install_galaxy.sh

./install_xcode_tools.sh
./install_homebrew.sh
./install_zsh.sh
./install_oh-my-zsh.sh
./install_python_3.sh
./install_galaxy.sh

echo "Setup completed successfully."
