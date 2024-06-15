# Source the galaxy control scripts
source "$(dirname "$0")/galaxy_start.sh"
source "$(dirname "$0")/galaxy_stop.sh"

# Optionally create aliases
alias galaxy_start='galaxy_start.sh'
alias galaxy_stop='galaxy_stop.sh'

