#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

log_info "Updating $GALAXY_CONFIG_PATH with conda settings..."

# Find conda_prefix and conda_exec
conda_prefix=$(conda info --base)
conda_exec=$(which conda)

log_info "Conda prefix: $conda_prefix"
log_info "Conda executable: $conda_exec"

# Check if galaxy.yml exists, if not copy the sample file
if [ ! -f "$GALAXY_CONFIG_PATH" ]; then
    log_info "galaxy.yml not found in $GALAXY_DIR/config/. Copying over the sample galaxy.yml..."
    cp "$GALAXY_DIR/config/galaxy.yml.sample" "$GALAXY_CONFIG_PATH"
fi

# Update galaxy.yml with yq
yq eval ".conda.prefix = \"$conda_prefix\"" -i "$GALAXY_CONFIG_PATH"
yq eval ".dependency_resolvers[0].conda_exec = \"$conda_exec\"" -i "$GALAXY_CONFIG_PATH"

log_info "$GALAXY_CONFIG_PATH has been updated with conda settings."
