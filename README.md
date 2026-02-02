# On-the-Fly Cryo-ET

Docker containers for on-the-fly cryo-electron tomography (cryo-ET) data processing.

## Overview

This repository provides Docker images for essential cryo-ET processing tools, enabling real-time tomographic reconstruction and analysis during data collection.

### Available Images

| Image | Description | Tools Included |
|-------|-------------|----------------|
| **cryoem-suite** | All-in-one container | WarpTools, AreTomo2, RELION 5 |
| **warp** | Motion correction & CTF | WarpTools 2.0 |
| **relion** | Single particle & STA | RELION 5 |
| **aretomo2** | Tomo alignment & recon | AreTomo2 |

## Quick Start

### Prerequisites

- Docker with NVIDIA GPU support ([nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)) OR Singularity/Apptainer
- NVIDIA GPU with compute capability 5.0+ (Pascal or newer recommended)

### Using Pre-built Images

#### Docker

```bash
# Pull the all-in-one image
docker pull wabuala/cryo-et-on-the-fly:latest

# Run with GPU support
docker run --gpus all -v /path/to/data:/data -it wabuala/cryo-et-on-the-fly
```

#### Singularity/Apptainer

```bash
# Pull and convert from Docker registry
singularity pull cryoem-suite.sif docker://wabuala/cryo-et-on-the-fly:latest

# Run with GPU support
singularity exec --nv cryoem-suite.sif WarpTools --help
singularity exec --nv cryoem-suite.sif AreTomo2 --help
singularity exec --nv cryoem-suite.sif relion --help

# Interactive shell
singularity shell --nv cryoem-suite.sif
```

#### Using the Wrapper Scripts (Recommended for Singularity)

For easier command-line usage with Singularity, use the provided wrapper scripts in the `bin/` directory:

```bash
# Set up the wrappers (one-time setup)
source bin/setup.sh /path/to/cryoem-suite.sif

# Now run tools directly
WarpTools ts_import --help
AreTomo2 -InMrc input.mrc -OutMrc output.mrc
relion_refine --help
```

See [`bin/README.md`](bin/README.md) for detailed setup instructions.

### Building from Source

```bash
# Clone the repository
git clone https://github.com/walidabualafia/on-the-fly-cryo-et.git
cd on-the-fly-cryo-et

# Build the combined image
cd dockerfiles/cryoem-suite
docker build --platform linux/amd64 -t cryoem-suite .
```

## Documentation

- [Installation Guide](docs/installation.md)
- [Usage Guide](docs/usage.md)
- [Individual Dockerfiles](dockerfiles/README.md)

## Tools

### WarpTools

[WarpTools](https://github.com/warpem/warp) provides GPU-accelerated pre-processing for cryo-EM data, including:
- Motion correction
- CTF estimation
- Real-time processing capabilities

### AreTomo2

[AreTomo2](https://github.com/czimaginginstitute/AreTomo2) offers fully automated:
- Marker-free tomographic alignment
- CTF estimation for tilt series
- Tomogram reconstruction

### RELION 5

[RELION](https://github.com/3dem/relion) is a comprehensive package for:
- Single particle analysis
- Subtomogram averaging
- 3D reconstruction

## System Requirements

### Build Requirements

- 16GB+ RAM recommended (8GB minimum)
- 30GB+ disk space
- Docker with BuildKit support

### Runtime Requirements

- NVIDIA GPU with 8GB+ VRAM
- CUDA 11.8+ compatible driver
- Docker with nvidia-container-toolkit

## License

The Dockerfiles in this repository are provided under the MIT License.

Note: The tools themselves (WARP, AreTomo2, RELION) have their own licenses:
- WARP: [License](https://github.com/warpem/warp/blob/main/LICENSE)
- AreTomo2: BSD-3-Clause
- RELION: GPLv2

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Acknowledgments

- [Bharat Lab](https://www.mrc-lmb.cam.ac.uk/bharat) for WARP
- [Chan Zuckerberg Imaging Institute](https://www.czii.org/) for AreTomo2
- [Scheres Lab](https://www2.mrc-lmb.cam.ac.uk/groups/scheres/) for RELION
