#! /bin/sh
# config.sh

# Configuration settings for Galaxy installation and management scripts.

# Defines Galaxy installation directory.
# NOTE! This path HAS TO BE SHORT or Galaxy will fail to start supervisord !!
export GALAXY_DIR="${HOME}/galaxy"
# Defines where Galaxy's UI service is serving.
# NOTE! This currently only changes where we look for Galaxy. It doesn't currently change any configs in Galaxy's cloned repo to actually stand it up at some other URL.
export GALAXY_INSTANCE_URL="http://localhost:8080"
# Defines where our Galaxy config info will go.
export GALAXY_CONFIG_PATH="${GALAXY_DIR}/config/galaxy.yml"
# Defines the default admin username for this project to create and use.
export DEFAULT_GALAXY_ADMIN_NAME="INSTALL_GALAXY_PROJECT_ADMIN"
# Defines the default admin user email for this project to create and use.
export DEFAULT_GALAXY_ADMIN_EMAIL="install-galaxy-project@admin.com"
# Defines the password for this user. If this is not a personal instance of Galaxy, you'll want to change this in Galaxy after install.
export DEFAULT_GALAXY_ADMIN_STARING_PW="update-in-galaxy-if-this-instance-is-shared"


# Defines where our remote ToolShed git repo can be found.
# NOTE! The ToolShed is currently expected to be a public repository, or a private repository this machine can already access. More work is required to make managing access keys by this installer automatic.
export TOOL_SHED_REPO="https://github.com/finkbeiner-lab/Galaxy_Tool_Shed.git"
# Defines the directory where we'll clone our ToolShed into.
export TOOL_SHED_DIR="$HOME/finkbeiner_tool_shed"
# Defines the "name" of the ToolShed, can be anything.
export TOOL_SHED_NAME="Finkbeiner Tool Shed"
# Defines the name of the owner of the  toolshed.
export TOOL_SHED_OWNER_NAME="finkbeiner-lab"

# The location this installer will use to download and run its scripts.
export GALAXY_INSTALLER_TMP_DIR="/tmp/galaxy_installer"
# The location of shell scripts from root. Note that the common files that a user might change, such as this config, will live in the project root, regardless if they are shell-based.
export SHELL_SCRIPTS_DIR="shell"
# The location of python helper scripts from root, and common python related scripts and files. Note that the python helper scripts themselves will be in their own subdirectories in the python directory.
export PYTHON_SCRIPTS_DIR="python"

