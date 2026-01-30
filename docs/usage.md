# Usage Guide

This guide covers common workflows using the cryo-ET containers.

## Basic Usage

### Running Containers

All containers follow the same pattern:

```bash
docker run --gpus all -v /path/to/data:/data -it <image-name> <command>
```

- `--gpus all` - Enable GPU access
- `-v /path/to/data:/data` - Mount your data directory
- `-it` - Interactive mode with terminal

### Data Organization

Recommended directory structure:

```
/data/
├── raw/              # Raw tilt series
│   ├── ts_001.mrc
│   └── ts_001.mdoc
├── frames/           # Movie frames (if applicable)
├── processed/        # Processing output
│   ├── aligned/
│   ├── ctf/
│   └── tomograms/
└── relion/           # RELION project
```

## Workflow Examples

### On-the-Fly Tomography Pipeline

#### Step 1: Import and Pre-process with WarpTools

```bash
docker run --gpus all -v /data:/data -it cryoem-suite

# Inside container, activate warp
source /opt/conda/etc/profile.d/conda.sh
conda activate warp

# Import tilt series
WarpTools ts_import \
    --mdocs /data/raw/*.mdoc \
    --frameseries /data/frames/ \
    --output /data/processed/warp/

# Motion correction and CTF
WarpTools ts_ctf \
    --settings /data/processed/warp/settings.xml \
    --range_max 6
```

#### Step 2: Align and Reconstruct with AreTomo2

```bash
# Run AreTomo2 on each tilt series
docker run --gpus all -v /data:/data cryoem-suite \
    AreTomo2 \
    -InMrc /data/processed/aligned/ts_001.mrc \
    -OutMrc /data/processed/tomograms/ts_001_rec.mrc \
    -AngFile /data/processed/aligned/ts_001.tlt \
    -VolZ 1200 \
    -OutBin 4 \
    -TiltCor 1 \
    -Gpu 0
```

#### Step 3: Subtomogram Averaging with RELION

```bash
# Launch RELION GUI
docker run --gpus all \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /data:/data \
    -it cryoem-suite relion

# Or run command-line jobs
docker run --gpus all -v /data:/data cryoem-suite \
    mpirun -n 4 relion_refine_mpi \
    --i particles.star \
    --o Refine3D/run1 \
    --ref initial_model.mrc \
    --auto_refine \
    --gpu
```

### Batch Processing

#### Process Multiple Tilt Series

```bash
#!/bin/bash
# process_all.sh

DATA_DIR=/path/to/data

for ts in $DATA_DIR/raw/*.mrc; do
    name=$(basename $ts .mrc)
    
    docker run --gpus all -v $DATA_DIR:/data cryoem-suite \
        AreTomo2 \
        -InMrc /data/raw/${name}.mrc \
        -OutMrc /data/tomograms/${name}_rec.mrc \
        -AngFile /data/raw/${name}.tlt \
        -VolZ 1200 \
        -OutBin 4 \
        -Gpu 0
done
```

## Tool-Specific Commands

### WarpTools Common Commands

```bash
# Import tilt series
WarpTools ts_import --mdocs *.mdoc --output ./warp/

# CTF estimation
WarpTools ts_ctf --settings settings.xml

# Export for RELION
WarpTools ts_export_particles \
    --settings settings.xml \
    --coords coords.star \
    --output particles/
```

### AreTomo2 Common Parameters

```bash
AreTomo2 \
    -InMrc input.mrc \        # Input tilt series
    -OutMrc output.mrc \      # Output tomogram
    -AngFile angles.tlt \     # Tilt angles (optional)
    -VolZ 1200 \              # Z thickness in pixels
    -OutBin 4 \               # Binning factor
    -TiltCor 1 \              # Correct tilt angles
    -FlipVol 1 \              # Flip volume
    -AlignZ 800 \             # Z for alignment
    -Gpu 0                    # GPU ID
```

### RELION Common Commands

```bash
# Import tomograms
relion_import --do_tomo --i "*.mrc" --odir Import/

# Extract subtomograms
relion_tomo_extract_particles \
    --i particles.star \
    --o Extract/ \
    --box 200

# 3D refinement
mpirun -n 4 relion_refine_mpi \
    --i particles.star \
    --o Refine3D/run1 \
    --ref reference.mrc \
    --auto_refine \
    --split_random_halves \
    --gpu
```

## GUI Access

### X11 Forwarding (Linux)

```bash
# Allow Docker X11 access
xhost +local:docker

# Run GUI application
docker run --gpus all \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /data:/data \
    -it cryoem-suite relion
```

### Remote Display (SSH)

```bash
# SSH with X11 forwarding
ssh -X user@server

# Run container
docker run --gpus all \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /data:/data \
    -it cryoem-suite relion
```

## Performance Tips

1. **Use local storage** - Mount data from fast local disks, not network storage
2. **Allocate all GPUs** - Use `--gpus all` for multi-GPU jobs
3. **Adjust binning** - Use higher binning for initial reconstructions
4. **Limit I/O** - Process data in batches to reduce disk I/O

## Troubleshooting

### "CUDA out of memory"

- Increase `--OutBin` for AreTomo2
- Reduce `--j` (threads) for RELION
- Process fewer particles per batch

### Slow performance

- Check GPU utilization: `nvidia-smi`
- Ensure data is on local disk
- Verify container has GPU access

### Permission denied on output files

```bash
# Run container with your user ID
docker run --gpus all \
    --user $(id -u):$(id -g) \
    -v /data:/data \
    cryoem-suite <command>
```
