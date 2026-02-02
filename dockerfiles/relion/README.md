# RELION 5 Container

Container with RELION 5 for cryo-EM structure determination.

## Features

- Single particle analysis
- Subtomogram averaging
- 3D classification and refinement
- CTF refinement and polishing
- GUI support (with X11 forwarding)

## Building

```bash
docker build --platform linux/amd64 -t relion5 .
```

## Running

### Command Line

```bash
# Show available commands
docker run --gpus all relion5 ls /opt/relion/bin/

# Run a RELION command
docker run --gpus all -v /path/to/data:/data relion5 \
    relion_refine --help
```

### GUI (requires X11)

```bash
# On Linux, allow Docker to access X11
xhost +local:docker

# Run RELION GUI
docker run --gpus all \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /path/to/data:/data \
    -it relion5 relion
```

## Key Commands

| Command | Purpose |
|---------|---------|
| `relion` | Launch GUI |
| `relion_refine` | 3D refinement |
| `relion_refine_mpi` | Parallel 3D refinement |
| `relion_class3d` | 3D classification |
| `relion_ctf_refine` | CTF refinement |
| `relion_motion_refine` | Bayesian polishing |

## Using with Singularity/Apptainer

```bash
# Pull/convert the image
singularity pull relion5.sif docker://ghcr.io/walidabualafia/relion5:latest

# Run RELION commands
singularity exec --nv relion5.sif relion_refine --help
singularity exec --nv relion5.sif relion_reconstruct --help

# With data binding
singularity exec --nv --bind /scratch:/scratch relion5.sif \
    relion_refine --o /scratch/output/run --i /scratch/data/particles.star

# Launch GUI (X11 forwarding usually works automatically with Singularity)
singularity exec --nv relion5.sif relion
```

### HPC Usage with SLURM

```bash
#!/bin/bash
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

singularity exec --nv /path/to/relion5.sif \
    relion_refine_mpi --o output/run --i particles.star --ref reference.mrc \
    --pool 30 --j 8 --gpu
```

See [RELION documentation](https://relion.readthedocs.io/) for full usage.
