# CryoEM-Suite: Unified container with WarpTools, AreTomo2, and RELION 5
# Platform: linux/amd64 (required for CUDA)
#
# This container provides a complete cryo-EM processing environment with:
# - WarpTools (via conda) - Pre-processing and CTF estimation
# - AreTomo2 - Tomographic alignment and reconstruction
# - RELION 5 - Single particle analysis and subtomogram averaging
#
# Build: docker build --platform linux/amd64 -t cryoem-suite .
# Run:   docker run --gpus all -v /path/to/data:/data -it cryoem-suite

FROM --platform=linux/amd64 nvidia/cuda:11.8.0-devel-ubuntu22.04

LABEL maintainer="CryoEM Suite"
LABEL description="Unified cryo-EM container: WarpTools + AreTomo2 + RELION 5"
LABEL version="1.0"

ENV DEBIAN_FRONTEND=noninteractive

# =============================================================================
# STAGE 1: Install system dependencies
# =============================================================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    cmake \
    git \
    build-essential \
    wget \
    ca-certificates \
    pkg-config \
    # MPI for RELION
    mpi-default-bin \
    mpi-default-dev \
    # Libraries for RELION
    libfftw3-dev \
    libtiff-dev \
    libpng-dev \
    ghostscript \
    libxft-dev \
    libx11-dev \
    libxext-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxi-dev \
    libfltk1.3-dev \
    # Compression utilities for RELION
    pbzip2 \
    xz-utils \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# STAGE 2: Install Miniforge and WarpTools (conda-based)
# =============================================================================

# Install Miniforge
RUN wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh

ENV PATH=/opt/conda/bin:$PATH

# Install WarpTools from conda (official pre-built package)
# This uses CUDA 11.8 for GPU acceleration
RUN conda create -n warp warp -c warpem -c nvidia/label/cuda-11.8.0 -c pytorch -c conda-forge -y && \
    conda clean -a -y

# =============================================================================
# STAGE 3: Build AreTomo2 from source
# =============================================================================

WORKDIR /build

# Clone AreTomo2 repository
RUN git clone https://github.com/czimaginginstitute/AreTomo2.git

# Build AreTomo2 with CUDA 11.8
# Using makefile11 for CUDA 11.x compatibility
WORKDIR /build/AreTomo2
RUN make exe -f makefile11 CUDAHOME=/usr/local/cuda

# Install AreTomo2 to /usr/local/bin
RUN cp AreTomo2* /usr/local/bin/ 2>/dev/null || \
    find . -maxdepth 1 -name "AreTomo2*" -type f -executable -exec cp {} /usr/local/bin/ \;

# =============================================================================
# STAGE 4: Build RELION 5 from source
# =============================================================================

WORKDIR /build

# Clone RELION repository
RUN git clone https://github.com/3dem/relion.git

# Checkout stable version 5.0
WORKDIR /build/relion
RUN git checkout ver5.0

# Create build directory and configure with CMake
# Note: Using system CUDA 11.8, enabling GPU support
# Using -j4 to limit parallel jobs and reduce memory usage
RUN mkdir build && cd build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=/opt/relion \
        -DGUI=ON \
        -DFORCE_OWN_FFTW=ON \
        -DFORCE_OWN_FLTK=ON \
        && \
    make -j4 && \
    make install

# =============================================================================
# STAGE 5: Environment setup and cleanup
# =============================================================================

# Set environment variables for all tools
ENV PATH=/opt/relion/bin:/usr/local/bin:/opt/conda/envs/warp/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/relion/lib:/usr/local/cuda/lib64:/opt/conda/envs/warp/lib:$LD_LIBRARY_PATH
ENV RELION_CTFFIND_EXECUTABLE=/opt/conda/envs/warp/bin/ctffind

# Create data directories
RUN mkdir -p /data/input /data/output

# Cleanup build artifacts to reduce image size
RUN rm -rf /build/AreTomo2 && \
    rm -rf /build/relion/build && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# STAGE 6: Entry point and default command
# =============================================================================

WORKDIR /data

# Create a wrapper script for activating conda env when needed
RUN echo '#!/bin/bash\n\
source /opt/conda/etc/profile.d/conda.sh\n\
conda activate warp\n\
exec "$@"' > /usr/local/bin/with-warp && \
    chmod +x /usr/local/bin/with-warp

# Default to bash shell - users can run any tool directly
CMD ["/bin/bash"]
