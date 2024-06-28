#!/bin/sh                                                                                                                                                                                                                                                                                                                                                         

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"  

# Function to pull down a shallow clone of the Galaxy repo from latest
pull_repo() {
    if [ ! -d "$GALAXY_DIR" ]; then
        log_info "Cloning Galaxy repository (shallow) into $GALAXY_DIR..."
        git clone --depth 1 https://github.com/galaxyproject/galaxy.git "$GALAXY_DIR"
    else
        log_info "Galaxy is already installed. Attempting to fast-forward to the latest version..."
        log_info "Checking out Galaxy's main branch 'dev' for updating..."
        git -C "$GALAXY_DIR" checkout dev
        if git -C "$GALAXY_DIR" pull --depth 1; then
            log_info "Galaxy repository update through fast-forward was successful."
        else
            log_error "Cannot fast-forward. Your copy of Galaxy has diverged from the official repository. You can to resolve a merge manually if this is intentional, or delete $GALAXY_DIR and re-run this installer to get on the latest release."
            exit 1
        fi
    fi
}

# Function to get the latest tagged release matching the pattern v00.00.00, this filters out "dev" releases and other random tags
checkout_latest_release() {
    log_info "Finding latest release tag..."
    tags=$(git -C "$GALAXY_DIR" ls-remote --tags --refs origin | awk -F'/' '{print $3}')

    # Find the latest release tag matching the pattern v00.00.00
    latest_tag=$(printf "%s\n" "$tags" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
    log_info "Latest release tag found: $latest_tag"
    
    if [ -z "$latest_tag" ]; then
        log_error "No valid release tags found. Unsure how to continue."
        exit 1
    fi

    # Fetch the specific tag's code from upstream (as we are working in a shallow clone)
    log_info "Pulling the code down for the tag: $latest_tag..." 
    git -C "$GALAXY_DIR" fetch --depth 1 origin tag $latest_tag

    # Check out the latest tagged release
    log_info "Checking out latest release version: $latest_tag..."
    if git -C "$GALAXY_DIR" checkout "$latest_tag"; then
        log_info "Checked out latest release: $latest_tag"
    else
        log_error "Unable to check out the latest release. Unsure how to continue. You'll need to either resolve manually or simply delete $GALAXY_DIR and re-run this installer."
        exit 1
    fi
}

# Function to move existing galaxy.yml to temporary directory if it exists
move_existing_galaxy_config() {
    if [ -f "$GALAXY_CONFIG_PATH" ]; then
        log_info "Existing galaxy.yml found. Backing it up into the installers temp directory $GALAXY_INSTALLER_TMP_DIR..."
 
        # Generate a random identifier as to not overwrite other backups if the installer is re-run
        random_id=$(date +%s%N)
        
        mv "$GALAXY_CONFIG_PATH" "$GALAXY_INSTALLER_TMP_DIR/galaxy.yml.backup.$random_id"
        if [ $? -eq 0 ]; then
            log_info "galaxy.yml moved to $GALAXY_INSTALLER_TMP_DIR/galaxy.yml.backup.$random_id"
        else
            log_error "Failed to move existing galaxy.yml to $GALAXY_INSTALLER_TMP_DIR"
            exit 1
        fi
    else
        log_info "No existing galaxy.yml found. Proceeding with setup..."
    fi
}

##############################
######## Script Start ########
##############################


log_info "Cloning Galaxy..."
log_info "Galaxy will be cloned into $GALAXY_DIR"

# If we already have a galaxy.yml, we're going to need to back it up and start fresh.
move_existing_galaxy_config

# Clone down or fast-forward Galaxy repo
pull_repo

# Calculate the latest release tag and check it out (base branch for galaxy is 'dev')
checkout_latest_release

log_info "Galaxy repository cloned and up to date."

