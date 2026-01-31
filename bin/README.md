# CryoEM-Suite Wrapper Scripts

This directory contains wrapper scripts that allow you to run tools from the cryoem-suite Singularity container as if they were installed locally.

Instead of running:
```bash
singularity exec --nv /path/to/cryoem-suite.sif WarpTools ts_import --help
```

You can simply run:
```bash
WarpTools ts_import --help
```

## Quick Start

### 1. Create the Singularity Container

If you haven't already, pull the container image:

```bash
singularity pull cryoem-suite.sif docker://ghcr.io/walidabualafia/cryoem-suite:latest
```

### 2. Create the Wrapper Symlinks

Run the setup script once to create all the wrapper symlinks:

```bash
cd bin
./create_wrappers.sh
```

### 3. Configure Your Environment

Source the setup script to configure the container path:

```bash
source setup.sh /path/to/cryoem-suite.sif
```

With optional bind mounts for external directories:

```bash
source setup.sh /path/to/cryoem-suite.sif --bind /scratch:/scratch
```

### 4. Run Tools

Now you can run any tool directly:

```bash
# WarpTools
WarpTools --help
WarpTools ts_import --mdocs /data/*.mdoc

# AreTomo2
AreTomo2 -InMrc input.mrc -OutMrc output.mrc -VolZ 1200

# RELION
relion_refine --help
relion_reconstruct --i particles.star --o output
```

## Adding to Your Shell Profile

To make the wrappers available in every new terminal, add to your `~/.bashrc` or `~/.bash_profile`:

```bash
# CryoEM-Suite wrappers - source setup.sh instead of setting variables manually
# This ensures proper handling of paths with spaces
source /path/to/on-the-fly-cryo-et/bin/setup.sh /path/to/cryoem-suite.sif
# Or with bind mounts:
# source /path/to/on-the-fly-cryo-et/bin/setup.sh /path/to/cryoem-suite.sif --bind /scratch:/scratch
```

## Available Tools

### WarpTools / M Suite
- `WarpTools` - Main WarpTools command
- `MTools` - M processing tools
- `MCore` - M core utilities
- `MrcConverter` - MRC format converter
- `WarpWorker` - Warp worker process
- `EstimateWeights` - Weight estimation
- `Frankenmap` - Map combination
- `Noise2Half`, `Noise2Map`, `Noise2Mic`, `Noise2Tomo` - Denoising tools

### AreTomo2
- `AreTomo2` - Tomographic alignment and reconstruction

### RELION 5
All standard RELION commands, including:
- `relion` - RELION GUI
- `relion_refine` / `relion_refine_mpi` - 3D refinement
- `relion_reconstruct` / `relion_reconstruct_mpi` - Reconstruction
- `relion_ctf_refine` - CTF refinement
- `relion_motion_refine` - Bayesian polishing
- `relion_tomo_*` - Tomography-specific commands
- And many more...

Run `ls -1 bin/ | grep relion` to see all available RELION commands.

## How It Works

The wrapper system uses:
1. **`_wrapper.sh`** - A generic wrapper script that runs commands inside the Singularity container
2. **Symlinks** - Each tool name is a symlink to `_wrapper.sh`
3. **Environment Variables**:
   - `CRYOEM_CONTAINER` - Absolute path to the Singularity SIF file (automatically converted from relative paths)
   - `CRYOEM_BIND_ARGS_ENCODED` - Base64-encoded bind mount arguments (handles paths with spaces)

When you run a command like `WarpTools`, the symlink points to `_wrapper.sh`, which:
1. Determines which command was invoked (from the symlink name)
2. Runs `singularity exec --nv $CRYOEM_BIND_OPTS $CRYOEM_CONTAINER WarpTools "$@"`

## Troubleshooting

### "CRYOEM_CONTAINER environment variable not set"

You need to source the setup script first:
```bash
source setup.sh /path/to/cryoem-suite.sif
```

### "Container file not found"

Make sure the path to your SIF file is correct:
```bash
ls -la /path/to/cryoem-suite.sif
```

If you don't have the container yet:
```bash
singularity pull cryoem-suite.sif docker://ghcr.io/walidabualafia/cryoem-suite:latest
```

### "singularity command not found"

Singularity/Apptainer needs to be installed on your system. On HPC clusters, it may need to be loaded as a module:
```bash
module load singularity
# or
module load apptainer
```

### GPU not detected

Make sure you're on a node with GPU access and the `--nv` flag is being passed (it's included automatically by the wrapper).

Check GPU access:
```bash
singularity exec --nv /path/to/cryoem-suite.sif nvidia-smi
```

### Permission denied on wrapper scripts

Make sure the scripts are executable:
```bash
chmod +x create_wrappers.sh setup.sh _wrapper.sh
```
