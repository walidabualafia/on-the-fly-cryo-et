# CryoEM-Suite

All-in-one Docker container with WarpTools, AreTomo2, and RELION 5.

## Included Tools

| Tool | Version | Purpose |
|------|---------|---------|
| WarpTools | 2.0 | Motion correction, CTF estimation, pre-processing |
| AreTomo2 | Latest | Tomographic alignment and reconstruction |
| RELION | 5.0 | Single particle analysis, subtomogram averaging |

## Pre-built Image

A pre-built image is available from GitHub Container Registry:

```bash
docker pull wabuala/cryo-et-on-the-fly:latest
```

## Building from Source

```bash
docker build --platform linux/amd64 -t cryoem-suite .
```

**Build requirements:**
- 12-16GB RAM allocated to Docker
- 30GB+ disk space
- 30-60 minutes build time

**Memory-saving tip:** The Dockerfile uses `make -j4` instead of `make -j$(nproc)` to limit parallel compilation and reduce peak memory usage.

## Running

### Interactive Shell

```bash
docker run --gpus all -v /path/to/data:/data -it cryoem-suite
```

### Running Specific Tools

**WarpTools** (requires conda environment):
```bash
# Using the wrapper script
docker run --gpus all -v /path/to/data:/data -it cryoem-suite \
    with-warp WarpTools --help

# Or activate manually
docker run --gpus all -v /path/to/data:/data -it cryoem-suite \
    bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate warp && WarpTools --help"
```

**AreTomo2**:
```bash
docker run --gpus all -v /path/to/data:/data cryoem-suite \
    AreTomo2 -InMrc input.mrc -OutMrc output.mrc -VolZ 1200
```

**RELION**:
```bash
# Launch RELION GUI (requires X11 forwarding)
docker run --gpus all \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /path/to/data:/data \
    -it cryoem-suite relion

# Run RELION commands
docker run --gpus all -v /path/to/data:/data cryoem-suite \
    relion_refine --help
```

## Tool Locations

| Tool | Path | Command |
|------|------|---------|
| WarpTools | `/opt/conda/envs/warp/bin/` | `with-warp WarpTools <cmd>` |
| AreTomo2 | `/usr/local/bin/` | `AreTomo2 <options>` |
| RELION | `/opt/relion/bin/` | `relion_<command>` |

## Environment Variables

Pre-configured:
- `PATH` includes all tool directories
- `LD_LIBRARY_PATH` includes CUDA and library paths
- `RELION_CTFFIND_EXECUTABLE` points to CTFFIND

## Data Directories

Mount your data to `/data`:
- `/data/input` - input files
- `/data/output` - output files

## GPU Support

Uses CUDA 11.8 for compatibility with WarpTools. Ensure your driver supports CUDA 11.8+.

```bash
# Check GPU inside container
docker run --gpus all cryoem-suite nvidia-smi
```

## Using with Singularity/Apptainer

Convert the Docker image to Singularity format for HPC usage:

### Pull/Convert Image

```bash
singularity pull cryoem-suite.sif docker://wabuala/cryo-et-on-the-fly:latest
```

### Running with Singularity

**WarpTools:**
```bash
singularity exec --nv cryoem-suite.sif WarpTools --help
singularity exec --nv cryoem-suite.sif WarpTools ts_import --mdocs /data/*.mdoc
```

**AreTomo2:**
```bash
singularity exec --nv cryoem-suite.sif AreTomo2 \
    -InMrc /data/tilt_series.mrc \
    -OutMrc /data/tomogram.mrc \
    -VolZ 1200
```

**RELION:**
```bash
singularity exec --nv cryoem-suite.sif relion_refine --help
```

### Binding Data Directories

```bash
# Bind external storage
singularity exec --nv --bind /scratch:/scratch cryoem-suite.sif WarpTools --help

# Bind multiple directories
singularity exec --nv --bind /data1:/data1,/data2:/data2 cryoem-suite.sif AreTomo2 --help
```

### Using Wrapper Scripts

For convenient command-line usage, use the wrapper scripts in `bin/`:

```bash
# One-time setup
source ../../bin/setup.sh /path/to/cryoem-suite.sif

# Run tools directly
WarpTools ts_import --help
AreTomo2 -InMrc input.mrc -OutMrc output.mrc
relion_refine --o output --i particles.star
```

## Troubleshooting

**"GPU not found" (Docker):**
```bash
# Ensure nvidia-container-toolkit is installed
sudo apt install nvidia-container-toolkit
sudo systemctl restart docker
```

**"GPU not found" (Singularity):**
```bash
# Ensure you're using the --nv flag
singularity exec --nv cryoem-suite.sif nvidia-smi
```

**X11 display issues (RELION GUI):**
```bash
# On Linux host (Docker)
xhost +local:docker

# For Singularity
singularity exec --nv cryoem-suite.sif relion
```

**WarpTools not found:**
```bash
# Docker: Always use the with-warp wrapper or manually activate conda
docker run --gpus all -v /data:/data -it cryoem-suite with-warp WarpTools --help

# Singularity: WarpTools should be in PATH directly
singularity exec --nv cryoem-suite.sif WarpTools --help
```
