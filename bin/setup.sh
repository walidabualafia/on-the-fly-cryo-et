#!/bin/bash
# Setup script for cryoem-suite Singularity wrapper scripts
#
# Usage:
#   source setup.sh /path/to/cryoem-suite.sif
#   source setup.sh /path/to/cryoem-suite.sif --bind /scratch:/scratch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 1 ]; then
    echo "Usage: source setup.sh /path/to/cryoem-suite.sif [--bind PATHS]"
    echo ""
    echo "Example:"
    echo "  source setup.sh ./cryoem-suite.sif"
    echo "  source setup.sh ./cryoem-suite.sif --bind /scratch:/scratch"
    return 1 2>/dev/null || exit 1
fi

# Set container path (convert to absolute if relative)
if [[ "$1" = /* ]]; then
    export SIF_PATH="$1"
else
    export SIF_PATH="$(cd "$(dirname "$1")" 2>/dev/null && pwd)/$(basename "$1")"
fi
shift

# Parse --bind option
export SIF_BIND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --bind)
            SIF_BIND="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            return 1 2>/dev/null || exit 1
            ;;
    esac
done

# Verify container exists
if [ ! -f "$SIF_PATH" ]; then
    echo "Error: Container not found: $SIF_PATH"
    echo "Run: singularity pull cryoem-suite.sif docker://wabuala/cryo-et-on-the-fly:latest"
    return 1 2>/dev/null || exit 1
fi

# Add bin directory to PATH
if [[ ":$PATH:" != *":$SCRIPT_DIR:"* ]]; then
    export PATH="$SCRIPT_DIR:$PATH"
fi

echo "CryoEM-Suite configured: $SIF_PATH"
[ -n "$SIF_BIND" ] && echo "Bind mounts: $SIF_BIND"
