#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# Function to handle cleanup
cleanup() {
    log_info "Cleaning up Conda environment..."
    conda deactivate
    conda env remove -n galaxy_installer
    if [ $? -eq 0 ]; then
        log_info "Conda environment removed successfully."
    else
        log_error "Failed to remove Conda environment."
    fi
}

# Function to check if the Conda environment exists and remove it if it does
check_and_remove_env() {
    if conda env list | grep -q "galaxy_installer"; then
        log_info "Conda environment 'galaxy_installer' already exists. Removing it..."
        conda env remove -n galaxy_installer
        if [ $? -ne 0 ]; then
            log_error "Failed to remove existing Conda environment."
            exit 1
        fi
    fi
}

###############################
######## Script Start ########
##############################

# Trap the exit to ensure cleanup
trap cleanup EXIT

# Initialize Conda to ensure the necessary shell functions and environment variables are set
log_info "Initializing Conda..."
conda init --quiet "$(basename "${SHELL}")"

# Check and remove the existing Conda environment if it exists
check_and_remove_env

# Create Conda environment using the name defined in environment.yml
log_info "Creating Conda environment..."
conda env create -f "${PYTHON_SCRIPTS_DIR}/${1}/environment.yml"

if [ $? -ne 0 ]; then
    log_error "Failed to create Conda environment."
    exit 1
fi

conda activate galaxy_installer

# Call the Python script with arguments
log_info "Calling into Python helper script $1..."
PYTHON_OUTPUT=$(python3 "${PYTHON_SCRIPTS_DIR}/${1}/${1}.py" "${@:2}")
PYTHON_EXIT_CODE=$?

# Ensure the script returns the exit code of the Python script
if [ $PYTHON_EXIT_CODE -ne 0 ]; then
    log_error "Python script $1 failed with exit code $PYTHON_EXIT_CODE."
    echo "$PYTHON_OUTPUT"
    exit $PYTHON_EXIT_CODE
else
    log_info "Python script $1 completed successfully."
    echo "$PYTHON_OUTPUT"
    exit 0
fi

