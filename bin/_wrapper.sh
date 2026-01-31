#!/bin/bash
# Generic wrapper script for cryoem-suite Singularity container
# This script is called by symlinks with tool names
#
# The script uses the CRYOEM_CONTAINER environment variable to locate
# the Singularity container, and CRYOEM_BIND_ARGS_ENCODED for additional bindings.
#
# Set these by sourcing setup.sh:
#   source setup.sh /path/to/cryoem-suite.sif

# Get the name of the command being called (from the symlink name)
CMD_NAME="$(basename "$0")"

# Check if running from _wrapper.sh directly
if [ "$CMD_NAME" = "_wrapper.sh" ]; then
    echo "Error: This script should not be called directly."
    echo "Use the tool-specific wrapper scripts (e.g., WarpTools, AreTomo2, relion_refine)"
    echo "or run 'source setup.sh /path/to/container.sif' first."
    exit 1
fi

# Check if container is configured
if [ -z "$CRYOEM_CONTAINER" ]; then
    echo "Error: CRYOEM_CONTAINER environment variable not set."
    echo ""
    echo "Please run the setup script first:"
    echo "  source $(dirname "$0")/setup.sh /path/to/cryoem-suite.sif"
    exit 1
fi

# Check if container exists
if [ ! -f "$CRYOEM_CONTAINER" ]; then
    echo "Error: Container file not found: $CRYOEM_CONTAINER"
    echo ""
    echo "To create the container, run:"
    echo "  singularity pull cryoem-suite.sif docker://ghcr.io/walidabualafia/cryoem-suite:latest"
    exit 1
fi

# Decode bind arguments from base64-encoded null-separated string
# This preserves paths with spaces correctly
BIND_ARGS=()
if [ -n "$CRYOEM_BIND_ARGS_ENCODED" ]; then
    while IFS= read -r -d '' arg; do
        BIND_ARGS+=("$arg")
    done < <(echo "$CRYOEM_BIND_ARGS_ENCODED" | base64 -d)
fi

# Run the command in the container
# --nv enables NVIDIA GPU support
# "${BIND_ARGS[@]}" expands to properly quoted bind mount arguments
exec singularity exec --nv "${BIND_ARGS[@]}" "$CRYOEM_CONTAINER" "$CMD_NAME" "$@"
