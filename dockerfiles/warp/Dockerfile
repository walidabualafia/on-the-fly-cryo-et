# WarpTools Container
# Platform: linux/amd64 (required for CUDA)
#
# WarpTools provides GPU-accelerated pre-processing for cryo-EM:
# - Motion correction
# - CTF estimation
# - Real-time processing
#
# Build: docker build --platform linux/amd64 -t warptools .
# Run:   docker run --gpus all -v /path/to/data:/data -it warptools

FROM --platform=linux/amd64 nvidia/cuda:11.8.0-devel-ubuntu22.04

LABEL maintainer="CryoEM Tools"
LABEL description="WarpTools for cryo-EM pre-processing"
LABEL version="2.0"

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniforge
RUN wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh

ENV PATH=/opt/conda/bin:$PATH

# Install Warp from conda (official pre-built package)
RUN conda create -n warp warp -c warpem -c nvidia/label/cuda-11.8.0 -c pytorch -c conda-forge -y && \
    conda clean -a -y

# Create data directories
RUN mkdir -p /data/input /data/output

ENV PATH=/opt/conda/envs/warp/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/conda/envs/warp/lib:$LD_LIBRARY_PATH

WORKDIR /data

# Activate conda env and run command
ENTRYPOINT ["/bin/bash", "-c", "source /opt/conda/etc/profile.d/conda.sh && conda activate warp && exec \"$@\"", "--"]
CMD ["WarpTools", "--help"]
