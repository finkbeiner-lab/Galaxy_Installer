# config.sh
# Configuration settings for Galaxy installation and management scripts.

# Defines Galaxy installation directory
# NOTE! This path HAS TO BE SHORT or Galaxy will fail to start supervisord !!
export GALAXY_DIR="$HOME/galaxy"
# Defines where Galaxy's UI service is serving
# NOTE! This currently only changes where we look for Galaxy. It doesn't currently change any configs in Galaxy's cloned repo to actually stand it up at some other URL.
export GALAXY_INSTANCE_URL="http://localhost:8080"


# Defines where our remote ToolShed git repo can be found
# NOTE! The ToolShed is currently expected to be a public repository, or a private repository this machine can already access. More work is required to make managing access keys by this installer automatic.
export TOOL_SHED_REPO="https://github.com/finkbeiner-lab/Galaxy_Tool_Shed.git"
# Defines the directory where we'll clone our ToolShed into
export TOOL_SHED_DIR="$HOME/finkbeiner_tool_shed"
# Defines the "name" of the ToolShed, can be anything
export TOOL_SHED_NAME="Finkbeiner"

# The location this installer will use to download and run its scripts
export GALAXY_INSTALLER_TMP_DIR=/tmp/galaxy_installer"

