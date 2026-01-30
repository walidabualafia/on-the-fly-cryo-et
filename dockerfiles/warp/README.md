# WarpTools Container

Lightweight container with WarpTools for cryo-EM pre-processing.

## Features

- Motion correction
- CTF estimation
- Particle picking
- Real-time processing capabilities

## Building

```bash
docker build --platform linux/amd64 -t warptools .
```

## Running

```bash
# Show help
docker run --gpus all warptools

# Process data
docker run --gpus all -v /path/to/data:/data warptools \
    WarpTools ts_import --help

# Interactive shell
docker run --gpus all -v /path/to/data:/data -it warptools bash
```

## Tool Reference

WarpTools commands:
- `ts_import` - Import tilt series
- `ts_ctf` - CTF estimation for tilt series
- `ts_motion` - Motion correction
- `ts_reconstruct` - Tomogram reconstruction

See [WarpTools documentation](https://warpem.github.io/warp/user_guide/warptools/) for full usage.
