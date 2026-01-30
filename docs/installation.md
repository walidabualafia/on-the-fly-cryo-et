# Installation Guide

This guide covers how to build and install the cryo-ET Docker containers.

## Prerequisites

### Docker with NVIDIA GPU Support

1. **Install Docker**
   ```bash
   # Ubuntu/Debian
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Add your user to docker group
   sudo usermod -aG docker $USER
   ```

2. **Install NVIDIA Container Toolkit**
   ```bash
   # Add NVIDIA repository
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
       sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   
   # Install toolkit
   sudo apt-get update
   sudo apt-get install -y nvidia-container-toolkit
   
   # Restart Docker
   sudo systemctl restart docker
   ```

3. **Verify GPU access**
   ```bash
   docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
   ```

## Building the Containers

### Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/on-the-fly-cryo-et.git
cd on-the-fly-cryo-et
```

### Build Options

#### Option 1: All-in-One Container (Recommended)

```bash
cd dockerfiles/cryoem-suite
docker build --platform linux/amd64 -t cryoem-suite .
```

**Requirements:**
- 12-16GB RAM allocated to Docker
- 30GB disk space
- 30-60 minutes build time

#### Option 2: Individual Tool Containers

Build only what you need:

```bash
# WarpTools only
cd dockerfiles/warp
docker build --platform linux/amd64 -t warptools .

# RELION only
cd dockerfiles/relion
docker build --platform linux/amd64 -t relion5 .

# AreTomo2 only
cd dockerfiles/aretomo2
docker build --platform linux/amd64 -t aretomo2 .
```

### Build on Remote Server

If your local machine has limited resources, build on a remote server:

```bash
# SSH to remote server
ssh user@server

# Clone and build
git clone https://github.com/YOUR_USERNAME/on-the-fly-cryo-et.git
cd on-the-fly-cryo-et/dockerfiles/cryoem-suite
docker build --platform linux/amd64 -t cryoem-suite .

# Save image to file
docker save cryoem-suite | gzip > cryoem-suite.tar.gz

# Transfer to local machine
scp user@server:cryoem-suite.tar.gz .

# Load on local machine
gunzip -c cryoem-suite.tar.gz | docker load
```

## Converting to Singularity/Apptainer

For HPC clusters that use Singularity/Apptainer:

```bash
# Build Docker image first
docker build --platform linux/amd64 -t cryoem-suite .

# Save as tarball
docker save cryoem-suite -o cryoem-suite.tar

# Convert to SIF (on HPC cluster)
apptainer build cryoem-suite.sif docker-archive://cryoem-suite.tar
```

Or build directly from Docker Hub (when images are published):

```bash
apptainer build cryoem-suite.sif docker://ghcr.io/YOUR_USERNAME/cryoem-suite:latest
```

## Troubleshooting

### Build Fails with "No space left on device"

```bash
# Clean Docker cache
docker system prune -a

# Increase Docker disk allocation (Docker Desktop)
# Settings → Resources → Disk image size
```

### Build Killed (Out of Memory)

```bash
# Increase Docker memory allocation (Docker Desktop)
# Settings → Resources → Memory → 12-16GB

# Or build with limited parallelism
# Edit Dockerfile: change "make -j$(nproc)" to "make -j2"
```

### CUDA Version Mismatch

Ensure your NVIDIA driver supports the CUDA version in the container:
- CUDA 11.8 requires driver ≥ 450.80.02
- CUDA 12.2 requires driver ≥ 525.60.13

Check your driver version:
```bash
nvidia-smi
```

### Cannot Connect to Docker Daemon

```bash
# Restart Docker service
sudo systemctl restart docker

# Or restart Docker Desktop
```
