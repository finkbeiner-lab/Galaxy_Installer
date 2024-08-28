#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# Function to remove a Conda enviroment
remove_conda_environment() {
    local conda_environment_name="$1"
    log_info "Cleaning up Conda environment ${conda_environment_name}..."
    conda env remove -n "$conda_environment_name" --yes
    if [ $? -eq 0 ]; then
        log_info "Conda environment removed successfully."
    else
        log_error "Failed to remove Conda environment."
    fi
}


# Function to handle cleanup
cleanup() {
    local conda_environment_name="$python_script_and_conda_name" # global reference
    log_info "Deactivating Conda environment '${conda_environment_name}'..."
    conda deactivate
    remove_conda_environment "$conda_environment_name"
}

# Function to check if the Conda environment exists and remove it if it does
check_and_remove_env() {
    local conda_environment_name="$1"
    log_info "Checking for an existing Conda environment..."
    if conda env list | grep -q "$conda_environment_name"; then
        log_info "Conda environment '${conda_environment_name}' already exists. Removing it..."
        remove_conda_environment "$conda_environment_name"
    else
        log_info "No existing Conda environment."
    fi
}

# Function to create conda environment.
# Note that the name in environment.yml needs to match the conda environment name. This is also the name of the script that will be run, and in the directory that it is found.
create_conda_environment() {
    local python_script_dir="$1"
    log_info "Creating Conda environment..."
    conda env create -f "${PYTHON_SCRIPTS_DIR}/${python_script_dir}/environment.yml"
    if [ $? -ne 0 ]; then
        log_error "Failed to create Conda environment from ${PYTHON_SCRIPTS_DIR}/${python_script_dir}/environment.yml."
        exit 1
    else
        log_info "Created the Conda environment successfully."
    fi
}

# Function to call the Python script with parameters
call_python_script() {
    local python_script_name="$1"
    log_info "Calling into Python script $python_script_name..."

    PYTHON_OUTPUT=$(python3 "${PYTHON_SCRIPTS_DIR}/${python_script_name}/${python_script_name}.py" "${@:2}")
    PYTHON_EXIT_CODE=$?

    # Ensure the script returns the exit code of the Python script
    if [ $PYTHON_EXIT_CODE -ne 0 ]; then
        log_error "Python script $python_script_name failed with exit code $PYTHON_EXIT_CODE."
        echo "$PYTHON_OUTPUT"
        exit $PYTHON_EXIT_CODE
    else
        log_info "Python script $python_script_name completed successfully."
        echo "$PYTHON_OUTPUT"
        exit 0
    fi
}

###############################
######## Script Start ########
##############################

python_script_and_conda_name="$1" # Made globally avaialable strictly for the cleanup method
if [ -z "$python_script_and_conda_name" ]; then
    log_error "$0 must be called with a python script name parameter."
    exit 1
fi

# Trap the exit to ensure cleanup
trap cleanup EXIT # Uses the globally available python_script_name variable

# Initialize Conda to ensure the necessary shell functions and environment variables are set
log_info "Initializing Conda..."
conda init --quiet zsh

source ~/.zshrc # hack
log_error "We need to find a better way to init Conda so that we can source the user's zsh profile"

# Check and remove the existing Conda environment if it exists
check_and_remove_env "$python_script_and_conda_name"

# Create Conda environment using the name defined in environment.yml
create_conda_environment "$python_script_and_conda_name"

# Activate the Conda Environment
conda activate "$python_script_and_conda_name"
pip list # debug

# Call the Python script with arguments
call_python_script "$python_script_and_conda_name" "${@:2}"

