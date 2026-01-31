# AreTomo2 Container

Lightweight container with AreTomo2 for tomographic alignment and reconstruction.

## Features

- Marker-free tilt series alignment
- GPU-accelerated CTF estimation
- Tomogram reconstruction
- Real-time processing support

## Building

```bash
docker build --platform linux/amd64 -t aretomo2 .
```

## Running

```bash
# Show help
docker run --gpus all aretomo2

# Basic reconstruction
docker run --gpus all -v /path/to/data:/data aretomo2 \
    AreTomo2 -InMrc /data/tilt_series.mrc -OutMrc /data/tomogram.mrc -VolZ 1200

# Full pipeline with CTF correction
docker run --gpus all -v /path/to/data:/data aretomo2 \
    AreTomo2 \
    -InMrc /data/tilt_series.mrc \
    -OutMrc /data/tomogram.mrc \
    -AngFile /data/angles.tlt \
    -VolZ 1200 \
    -OutBin 4 \
    -TiltCor 1 \
    -FlipVol 1 \
    -Gpu 0
```

## Key Parameters

| Parameter | Description |
|-----------|-------------|
| `-InMrc` | Input tilt series MRC file |
| `-OutMrc` | Output tomogram file |
| `-AngFile` | Tilt angles file (optional) |
| `-VolZ` | Tomogram thickness in pixels |
| `-OutBin` | Output binning factor |
| `-TiltCor` | Enable tilt angle correction |
| `-FlipVol` | Flip volume orientation |
| `-Gpu` | GPU device ID(s) |

## GPU Memory

AreTomo2 recommends GPUs with 20GB+ VRAM for optimal performance. For smaller GPUs, increase `-OutBin` to reduce memory usage.

## Using with Singularity/Apptainer

```bash
# Pull/convert the image
singularity pull aretomo2.sif docker://ghcr.io/walidabualafia/aretomo2:latest

# Show help
singularity exec --nv aretomo2.sif AreTomo2 --help

# Basic reconstruction
singularity exec --nv aretomo2.sif AreTomo2 \
    -InMrc /path/to/tilt_series.mrc \
    -OutMrc /path/to/tomogram.mrc \
    -VolZ 1200

# With data binding
singularity exec --nv --bind /scratch:/scratch aretomo2.sif AreTomo2 \
    -InMrc /scratch/data/tilt_series.mrc \
    -OutMrc /scratch/output/tomogram.mrc \
    -AngFile /scratch/data/angles.tlt \
    -VolZ 1200 \
    -OutBin 4 \
    -TiltCor 1 \
    -FlipVol 1 \
    -Gpu 0
```

See [AreTomo2 documentation](https://github.com/czimaginginstitute/AreTomo2) for full usage.
