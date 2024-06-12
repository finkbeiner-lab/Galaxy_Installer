#!/bin/sh                                                                                                                                                                                                                                                                                                                                                         

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"  

# Function to clone down the Galaxy repo or pull from the latest release
pull_repo() {
    if [ ! -d "$GALAXY_DIR" ]; then
        log_info "Cloning Galaxy repository..."
        git clone https://github.com/galaxyproject/galaxy.git "$GALAXY_DIR"
    else
        log_info "Galaxy is already installed. Attempting to fast-forward to the latest version..."
        cd "$GALAXY_DIR"
        log_info "Checking out Galaxy's main branch 'dev' for updating..."
        git checkout dev
        if git pull; then
            log_info "Galaxy repository update through fast-forward was successful."
        else
            log_error "Cannot fast-forward. Your copy of Galaxy has diverged significantly from the official repository. You'll need to resolve a merge manually, or delete $GALAXY_DIR and start fresh."
            exit 1
        fi
    fi
}

# Function to get the latest tagged release matching the pattern v00.00.00, this filters out "dev" releases and other random tags
checkout_latest_release() {
    log_info "Finding latest release..."
    cd "$GALAXY_DIR"
    git fetch --tags

    # Find the latest tag matching the pattern
    latest_tag=$(git tag -l | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)

    # Log the found tag
    log_info "Latest tag found: $latest_tag"

    if [ -z "$latest_tag" ]; then
        log_error "No valid release tags found. Unsure how to continue."
        exit 1
    fi

    # Check out the latest tagged release
    log_info "Checking out latest release version: $latest_tag..."
    if git checkout "$latest_tag"; then
        log_info "Checked out latest release: $latest_tag"
    else
        log_error "Unable to check out the latest release. Unsure how to continue. You'll need to resolve manually or delete $GALAXY_DIR and start fresh."
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
