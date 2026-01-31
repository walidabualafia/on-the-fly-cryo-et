# Dockerfiles

This directory contains Dockerfiles for cryo-ET processing tools.

## Available Images

### cryoem-suite (Recommended)

The all-in-one container with WarpTools, AreTomo2, and RELION 5. Best for workflows that use multiple tools.

```bash
cd cryoem-suite
docker build --platform linux/amd64 -t cryoem-suite .
```

### Individual Tool Images

For lighter-weight containers with specific tools:

| Directory | Tool | Base Image | Size (approx) |
|-----------|------|------------|---------------|
| `warp/` | WarpTools 2.0 | CUDA 11.8 | ~8GB |
| `relion/` | RELION 5 | CUDA 12.2 | ~6GB |
| `aretomo2/` | AreTomo2 | CUDA 11.8 | ~4GB |

## Build Requirements

All images require:
- Docker with BuildKit
- `--platform linux/amd64` flag (required for CUDA compatibility)
- Sufficient RAM: 8-16GB allocated to Docker
- Sufficient disk: ~30GB for the combined image

## GPU Requirements

All images require NVIDIA GPUs at runtime:
- nvidia-container-toolkit installed (Docker) or `--nv` flag (Singularity)
- CUDA-compatible driver (11.8+ for most images)
- `--gpus all` flag when running Docker containers

## Using with Singularity/Apptainer

All Docker images can be converted to Singularity SIF files for use on HPC clusters:

```bash
# Convert any image to Singularity format
singularity pull cryoem-suite.sif docker://ghcr.io/walidabualafia/cryoem-suite:latest
singularity pull warptools.sif docker://ghcr.io/walidabualafia/warptools:latest
singularity pull relion5.sif docker://ghcr.io/walidabualafia/relion5:latest
singularity pull aretomo2.sif docker://ghcr.io/walidabualafia/aretomo2:latest

# Run with GPU support
singularity exec --nv cryoem-suite.sif <command>
```

### Binding Data Directories

Singularity automatically binds your home directory. For other paths:

```bash
singularity exec --nv --bind /scratch:/scratch cryoem-suite.sif WarpTools --help
```

### HPC Considerations

- SIF files are read-only and portable across nodes
- No root privileges required to run
- GPU access via `--nv` flag
- Works with SLURM and other job schedulers

## Base Images

| Image | CUDA Version | Ubuntu Version | Notes |
|-------|--------------|----------------|-------|
| cryoem-suite | 11.8 | 22.04 | WarpTools requires CUDA 11.8 |
| warp | 11.8 | 22.04 | Official conda package |
| relion | 12.2 | 22.04 | Supports newer GPUs |
| aretomo2 | 11.8 | 22.04 | Compatible with makefile11 |
