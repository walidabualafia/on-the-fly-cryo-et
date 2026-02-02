# CryoEM-Suite Wrapper Scripts

Wrapper scripts to run tools from the cryoem-suite Singularity container as native commands.

## Quick Start

### 1. Pull the Container

```bash
singularity pull cryoem-suite.sif docker://wabuala/cryo-et-on-the-fly:latest
```

### 2. Create Wrapper Symlinks (one-time)

```bash
cd bin
./create_wrappers.sh
```

### 3. Configure Environment

```bash
source setup.sh /path/to/cryoem-suite.sif

# With bind mounts:
source setup.sh /path/to/cryoem-suite.sif --bind /scratch:/scratch
```

### 4. Run Tools

```bash
WarpTools --help
AreTomo2 -InMrc input.mrc -OutMrc output.mrc -VolZ 1200
relion_refine --help
```

## Adding to Shell Profile

Add to `~/.bashrc`:

```bash
source /path/to/bin/setup.sh /path/to/cryoem-suite.sif
```

## Environment Variables

The setup script exports two variables:

| Variable | Description |
|----------|-------------|
| `SIF_PATH` | Absolute path to the container |
| `SIF_BIND` | Bind mount paths (optional) |

## How It Works

Each tool name (e.g., `WarpTools`) is a symlink to `_wrapper.sh`, which runs:

```bash
singularity exec --nv [--bind $SIF_BIND] $SIF_PATH <command> <args>
```

## Troubleshooting

**"SIF_PATH not set"** - Run `source setup.sh /path/to/cryoem-suite.sif`

**"Container not found"** - Pull the container:
```bash
singularity pull cryoem-suite.sif docker://wabuala/cryo-et-on-the-fly:latest
```

**"singularity not found"** - Load the module: `module load singularity` or `module load apptainer`
