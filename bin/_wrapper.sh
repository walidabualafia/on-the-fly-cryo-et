#!/bin/bash
# Generic wrapper - runs commands inside the Singularity container
# Called via symlinks (e.g., WarpTools -> _wrapper.sh)
#
# Requires: source setup.sh /path/to/container.sif

CMD_NAME="$(basename "$0")"

if [ "$CMD_NAME" = "_wrapper.sh" ]; then
    echo "Error: Don't call _wrapper.sh directly. Use tool symlinks (WarpTools, AreTomo2, etc.)"
    exit 1
fi

if [ -z "$SIF_PATH" ]; then
    echo "Error: SIF_PATH not set. Run: source setup.sh /path/to/cryoem-suite.sif"
    exit 1
fi

if [ ! -f "$SIF_PATH" ]; then
    echo "Error: Container not found: $SIF_PATH"
    echo "Run: singularity pull cryoem-suite.sif docker://wabuala/cryo-et-on-the-fly:latest"
    exit 1
fi

# Build command with optional bind mounts
if [ -n "$SIF_BIND" ]; then
    exec singularity exec --nv --bind "$SIF_BIND" "$SIF_PATH" "$CMD_NAME" "$@"
else
    exec singularity exec --nv "$SIF_PATH" "$CMD_NAME" "$@"
fi
