# common.py
import sys

#
# It is important to keep this in lockstep with common.sh to retain consistency in the outputs in our shell scrips and python scripts.
#

#Function to log informational messages
def log_info(message):
    print(f"\033[0;34m🔬 [INSTALL GALAXY PROJECT] {message}\033[0m")

# Function to log warning messages
def log_warning(message):
    print(f"\033[0;33m🔬 [WARNING] {message}\033[0m")

# Function to log error messages
def log_error(message):
    print(f"\033[0;31m🔬 [ERROR] {message}\033[0m", file=sys.stderr)
