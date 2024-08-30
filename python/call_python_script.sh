#!/bin/zsh

# Bring in common functions and configs
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../common.sh"

# Function to remove a Conda environment
remove_conda_environment() {
    local conda_environment_name="$1"
    if conda_env_exists "$conda_environment_name"; then
        log_info "Conda environment '${conda_environment_name}' already exists. Removing it..."
        conda env remove -n "$conda_environment_name" --yes
        if [ $? -eq 0 ]; then
            log_info "Conda environment removed successfully."
        else
            log_error "Failed to remove Conda environment."
            exit 1
        fi
    else
        log_info "No existing Conda environment to remove."
    fi
}

# Function to return if a Conda environment already exists
conda_env_exists() {
    local conda_environment_name="$1"
    log_info "Checking for an existing Conda environment..."
    if conda env list | grep -q "$conda_environment_name"; then
        return 0  # Environment exists
    else
        return 1  # Environment does not exist
    fi
}

# Function to handle cleanup
cleanup() {
    local conda_environment_name="$python_script_and_conda_name" # global reference
    log_info "Deactivating Conda environment '${conda_environment_name}'..."
    conda deactivate
    remove_conda_environment "$conda_environment_name"
}

# Function to create conda environment.
create_conda_environment() {
    local python_script_dir="$1"
    log_info "Creating Conda environment..."
    conda env create -f "python/$python_script_dir/environment.yml"  # Adjusted path to environment.yml
    if [ $? -ne 0 ]; then
        log_error "Failed to create Conda environment from python/$python_script_dir/environment.yml."
        exit 1
    else
        log_info "Created the Conda environment successfully."
    fi
}

# Function to call the Python script with parameters
call_python_script() {
    local python_script_name="$1"
    log_info "Calling into Python script $python_script_name..."

    local python_output
    local python_exit_code

    python_output=$(python3 "python/$python_script_name/$python_script_name.py" "${@:2}")
    python_exit_code=$?

    if [ $python_exit_code -ne 0 ]; then
        log_error "Python script $python_script_name failed with exit code $python_exit_code."
        echo "$python_output"
        exit $python_exit_code
    else
        log_info "Python script $python_script_name completed successfully."
        echo "$python_output"
        exit 0
    fi
}

###############################
######## Script Start ########
##############################

python_script_and_conda_name="$1" # Made globally available strictly for the cleanup method
if [ -z "$python_script_and_conda_name" ]; then
    log_error "$0 must be called with a python script name parameter."
    exit 1
fi

# Trap the exit to ensure cleanup
trap cleanup EXIT # Uses the globally available python_script_name variable

# Initialize Conda to ensure the necessary shell functions and environment variables are set
log_info "Initializing Conda..."
conda init --quiet zsh

# Source the updated shell environment to get Conda commands available
source ~/.zshrc

# Remove the existing Conda environment if it exists
remove_conda_environment "$python_script_and_conda_name"

# Create Conda environment using the name defined in environment.yml
create_conda_environment "$python_script_and_conda_name"

# Activate the Conda Environment
conda activate "$python_script_and_conda_name"

# Call the Python script with arguments
call_python_script "$python_script_and_conda_name" "${@:2}"
