#!/bin/zsh
source "$(dirname "$0")/common.sh"

log_info "Updating $GALAXY_CONFIG_PATH with conda settings..."

# Find conda_prefix and conda_exec
conda_prefix=$(conda info --base)
conda_exec=$(which conda)

log_info "Conda prefix: $conda_prefix"
log_info "Conda executable: $conda_exec"

# Update galaxy.yml with yq
yq eval ".conda.prefix = \"$conda_prefix\"" -i "$GALAXY_CONFIG_PATH"
yq eval ".dependency_resolvers[0].conda_exec = \"$conda_exec\"" -i "$GALAXY_CONFIG_PATH"

log_info "$GALAXY_CONFIG_PATH has been updated with conda settings."
