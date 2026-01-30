# CryoEM-Suite

All-in-one Docker container with WarpTools, AreTomo2, and RELION 5.

## Included Tools

| Tool | Version | Purpose |
|------|---------|---------|
| WarpTools | 2.0 | Motion correction, CTF estimation, pre-processing |
| AreTomo2 | Latest | Tomographic alignment and reconstruction |
| RELION | 5.0 | Single particle analysis, subtomogram averaging |

## Building

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

## Troubleshooting

**"GPU not found":**
```bash
# Ensure nvidia-container-toolkit is installed
sudo apt install nvidia-container-toolkit
sudo systemctl restart docker
```

**X11 display issues (RELION GUI):**
```bash
# On Linux host
xhost +local:docker
```

**WarpTools not found:**
```bash
# Always use the with-warp wrapper or manually activate conda
docker run --gpus all -v /data:/data -it cryoem-suite with-warp WarpTools --help
```
