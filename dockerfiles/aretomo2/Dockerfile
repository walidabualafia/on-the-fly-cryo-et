# AreTomo2 Container
# Platform: linux/amd64 (required for CUDA)
#
# AreTomo2 provides automated tomographic processing:
# - Marker-free alignment
# - CTF estimation
# - Tomogram reconstruction
#
# Build: docker build --platform linux/amd64 -t aretomo2 .
# Run:   docker run --gpus all -v /path/to/data:/data aretomo2 AreTomo2 --help

FROM --platform=linux/amd64 nvidia/cuda:11.8.0-devel-ubuntu22.04

LABEL maintainer="CryoEM Tools"
LABEL description="AreTomo2 for tomographic alignment and reconstruction"
LABEL version="latest"

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libtiff-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build AreTomo2
WORKDIR /build
RUN git clone https://github.com/czimaginginstitute/AreTomo2.git

WORKDIR /build/AreTomo2
RUN make exe -f makefile11 CUDAHOME=/usr/local/cuda

# Install binary
RUN cp AreTomo2* /usr/local/bin/ 2>/dev/null || \
    find . -maxdepth 1 -name "AreTomo2*" -type f -executable -exec cp {} /usr/local/bin/ \;

# Cleanup
RUN rm -rf /build

# Create data directory
RUN mkdir -p /data
WORKDIR /data

ENV PATH="/usr/local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

CMD ["AreTomo2", "--help"]
