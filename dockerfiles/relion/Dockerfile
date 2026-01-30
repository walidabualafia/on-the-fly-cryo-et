# RELION 5 Container
# Platform: linux/amd64 (required for CUDA)
#
# RELION provides comprehensive cryo-EM structure determination:
# - Single particle analysis
# - Subtomogram averaging
# - 3D reconstruction
#
# Build: docker build --platform linux/amd64 -t relion5 .
# Run:   docker run --gpus all -v /path/to/data:/data -it relion5

FROM --platform=linux/amd64 nvidia/cuda:12.2.0-devel-ubuntu22.04

LABEL maintainer="CryoEM Tools"
LABEL description="RELION 5 for cryo-EM structure determination"
LABEL version="5.0"

ENV DEBIAN_FRONTEND=noninteractive

# Install all required dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    git \
    build-essential \
    mpi-default-bin \
    mpi-default-dev \
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
    pbzip2 \
    xz-utils \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Clone RELION repository
WORKDIR /build
RUN git clone https://github.com/3dem/relion.git

# Checkout stable version and build
WORKDIR /build/relion
RUN git checkout ver5.0 && \
    mkdir build && cd build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=/opt/relion \
        -DGUI=ON \
        -DFORCE_OWN_FFTW=ON \
        -DFORCE_OWN_FLTK=ON \
        && \
    make -j4 && \
    make install

# Set environment variables
ENV PATH="/opt/relion/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/relion/lib:${LD_LIBRARY_PATH}"

# Cleanup build artifacts
RUN rm -rf /build

# Create data directory
RUN mkdir -p /data
WORKDIR /data

CMD ["/bin/bash"]
