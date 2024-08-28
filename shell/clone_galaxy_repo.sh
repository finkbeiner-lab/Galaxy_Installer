#!/bin/sh                                                                                                                                                                                                                                                                                                                                                         

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"  

# Storing the repository URL  in this file, rather than the config, because if it changes this whole script needs to be evaluated for changes.
GALAXY_REPO_URL="https://github.com/galaxyproject/galaxy.git"

# Function to stash local changes and return a boolean indicating whether there were changes to be stashed
stash_changes() {
    local repo_dir=$1
    local pre_stash_list
    local post_stash_list

    # Check stash list before stashing
    pre_stash_list=$(git -C "$repo_dir" stash list)

    # Stash any local changes
    git -C "$repo_dir" stash push -m "Auto-stash before updating Galaxy repo" > /dev/null 2>&1

    # Check stash list after stashing
    post_stash_list=$(git -C "$repo_dir" stash list)

    # Return true if changes were stashed, false otherwise
    [ "$pre_stash_list" != "$post_stash_list" ]
}

# Function to pull down a shallow clone of the Galaxy repository
pull_repo() {
    if [ ! -d "$GALAXY_DIR" ]; then
        log_info "Cloning Galaxy repository (shallow) from $GALAXY_REPO_URL into $GALAXY_DIR..."
        git clone --depth 1 "$GALAXY_REPO_URL" "$GALAXY_DIR"
    else
        log_info "Galaxy is already installed. Attempting to get the latest version..."
        
       
       # Stash any local changes
        log_info "Stashing any local changes..."
        if stash_changes "$GALAXY_DIR"; then
            did_stash=true
        else
            did_stash=false
        fi

        if [ "$did_stash" = true ]; then
            log_info "Changes stashed successfully."
        else
            log_info "No changes to stash."
        fi
        
        log_info "Checking out Galaxy's main branch 'dev' for updating..."
        if ! git -C "$GALAXY_DIR" checkout dev; then
            log_error "Failed to checkout 'dev' branch. Perhaps the Galaxy GitHub project has changed its structure and this script needs to be updated: $0"
            exit 1
        fi

        # The Galaxy GitHib project is mismanaged in some way where fast-forwards fail regularly, so we'll do a hard reset
        log_info "Fetching latest changes from the remote repository and performing a hard reset to adopt them..."
        if git -C "$GALAXY_DIR" fetch --depth 1 origin && git -C "$GALAXY_DIR" reset --hard origin/dev; then
            log_info "Galaxy repository update through hard reset was successful."

            # Apply stashed changes if any
            if [ "$did_stash" = true ]; then
                log_info "Applying stashed changes..."
                if ! git -C "$GALAXY_DIR" stash pop > /dev/null 2>&1; then
                    log_error "Failed to apply stashed changes. You may need to resolve conflicts manually in $GALAXY_DIR or delete it and re-run this installer to get a fresh release."
                    exit 1
                fi
            else
                log_info "No stashed changes that need to be applied."
            fi
       else
            log_error "Cannot get the latest version of the Galaxy GitHub project.. Your copy of Galaxy may have diverged from the official repository. Resolve the merge manually in $GALAXY_DIR or delete it and re-run this installer to get the latest release."
            log_error "If this reoccurs, the Galaxy GitHub project has likely diverged from us, and this script needs to be updated. $0"
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

# Attempt to roll the databases forward applying any DDL changes 
run_sqlalchemy_migrations() {
    log_info "Checking for Galaxy database migrations..."
    for db_migration_script in "$GALAXY_DIR"/*_db.sh; do
        [ -e "$db_migration_script" ] || continue  # Skip if no files match
        log_info "Found SQLAlchemy migration script: $db_migration_script"
        
        output=$("$db_migration_script" upgrade 2>&1)
        if [ $? -eq 0 ]; then
            log_info "$output"
            log_info "$db_migration_script upgrade successful."
        else
            log_warning "$output"
            log_warning "$db_migration_script unsuccessful."
            log_warning "These database structure migrations seem to fail frequently in the Galaxy project, and often we're unaffected."
            log_warning "In order to preserve any changes you've made to Galaxy, we're going to move forward even though this migration has failed."
            log_warning "HOWEVER. If Galaxy fails to start, you'll need to either resolve manually or simply delete $GALAXY_DIR and re-run this installer."
        fi
    done
    log_info "Database migrations complete."
}

##############################
######## Script Start ########
##############################


log_info "Cloning Galaxy..."
log_info "Galaxy will be cloned into $GALAXY_DIR"

# Clone down or fast-forward Galaxy repo
pull_repo

# Calculate the latest release tag and check it out (base branch for galaxy is 'dev')
checkout_latest_release

# Start the galaxy.yml in a clean state
log_info "We're going to back up the existing galaxy.yml, and start fresh. If there are custom configurations you've made, you'll need to copy them back in from the backup."
start_new_galaxy_config "$GALAXY_CONFIG_PATH" "$(dirname "$GALAXY_CONFIG_PATH")/galaxy.yml.sample"
if [ $? -ne 0 ]; then
    log_error "Unable to create a new clean galaxy.yml config file. There may be permissions issues or an issue with this install project."
    exit 1
fi

# Apply any Galaxy database DDL migrations
run_sqlalchemy_migrations

log_info "Galaxy repository cloned and up to date."

