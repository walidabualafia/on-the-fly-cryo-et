#!/bin/bash
# Setup script for cryoem-suite Singularity wrapper scripts
# Source this file to configure and enable the wrappers
#
# Usage:
#   source setup.sh /path/to/cryoem-suite.sif
#   source setup.sh /path/to/cryoem-suite.sif --bind /scratch:/scratch
#
# After sourcing, you can run tools directly:
#   WarpTools ts_import --help
#   AreTomo2 -InMrc input.mrc -OutMrc output.mrc
#   relion_refine --help

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Usage: source setup.sh /path/to/cryoem-suite.sif [--bind /path1:/mount1,/path2:/mount2]"
    echo ""
    echo "Options:"
    echo "  --bind    Additional bind mounts for Singularity (comma-separated)"
    echo ""
    echo "Example:"
    echo "  source setup.sh /path/to/cryoem-suite.sif"
    echo "  source setup.sh /path/to/cryoem-suite.sif --bind /scratch:/scratch"
    return 1 2>/dev/null || exit 1
fi

# Set container path - convert to absolute path to handle relative paths
# This ensures the path remains valid even if the user changes directories
if [[ "$1" = /* ]]; then
    # Already absolute path
    CRYOEM_CONTAINER="$1"
else
    # Convert relative path to absolute
    CRYOEM_CONTAINER="$(cd "$(dirname "$1")" 2>/dev/null && pwd)/$(basename "$1")"
fi
shift

# Parse optional arguments
# Use an array to properly handle paths with spaces
CRYOEM_BIND_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --bind)
            CRYOEM_BIND_ARGS+=("--bind" "$2")
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            return 1 2>/dev/null || exit 1
            ;;
    esac
done

# Verify container exists
if [ ! -f "$CRYOEM_CONTAINER" ]; then
    echo "Error: Container file not found: $CRYOEM_CONTAINER"
    echo ""
    echo "To create the container, run:"
    echo "  singularity pull cryoem-suite.sif docker://ghcr.io/walidabualafia/cryoem-suite:latest"
    return 1 2>/dev/null || exit 1
fi

# Verify singularity is available
if ! command -v singularity &> /dev/null; then
    echo "Error: singularity command not found"
    echo "Please install Singularity/Apptainer first"
    return 1 2>/dev/null || exit 1
fi

# Export environment variables for the wrappers
export CRYOEM_CONTAINER
# Export array as a specially-formatted string that preserves spaces
# Format: null-separated values, base64 encoded
if [ ${#CRYOEM_BIND_ARGS[@]} -gt 0 ]; then
    export CRYOEM_BIND_ARGS_ENCODED
    CRYOEM_BIND_ARGS_ENCODED="$(printf '%s\0' "${CRYOEM_BIND_ARGS[@]}" | base64)"
else
    export CRYOEM_BIND_ARGS_ENCODED=""
fi

# Add bin directory to PATH if not already there
if [[ ":$PATH:" != *":$SCRIPT_DIR:"* ]]; then
    export PATH="$SCRIPT_DIR:$PATH"
fi

# Print success message
echo "CryoEM-Suite wrapper scripts configured!"
echo ""
echo "Container: $CRYOEM_CONTAINER"
if [ ${#CRYOEM_BIND_ARGS[@]} -gt 0 ]; then
    echo "Bind options: ${CRYOEM_BIND_ARGS[*]}"
fi
echo ""
echo "Available tools:"
echo "  - WarpTools, MTools, MCore, and other Warp utilities"
echo "  - AreTomo2"
echo "  - RELION 5 commands (relion_refine, relion_reconstruct, etc.)"
echo ""
echo "Run any tool directly, e.g.:"
echo "  WarpTools --help"
echo "  AreTomo2 --help"
echo "  relion_refine --help"
