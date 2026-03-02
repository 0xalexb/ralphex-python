# ralphex-python

Python development image extending the [ralphex](https://github.com/umputun/ralphex) base image with [UV](https://docs.astral.sh/uv/) (fast Python package manager) and [ruff](https://docs.astral.sh/ruff/) (linter/formatter). Each image variant includes a specific Python version installed and managed via UV.

## Available Tags

| Tag      | Python Version | Notes          |
|----------|---------------|----------------|
| `3.13`   | 3.13          | Also tagged `latest` |
| `3.12`   | 3.12          |                |
| `3.11`   | 3.11          |                |
| `latest` | 3.13          | Alias for `3.13` |

## What's Included

From the base image (`ghcr.io/umputun/ralphex:latest`):
- System Python 3, pip
- Node.js, npm
- make, gcc, musl-dev
- git, bash
- ripgrep, fzf
- Claude Code, Codex

Added by this image:
- UV (default: 0.10.6) - fast Python package manager
- ruff (default: 0.15.3) - Python linter and formatter
- Python version matching the image tag, installed and managed via UV

## Usage

Pull a specific Python version:

```
docker pull ghcr.io/0xalexb/ralphex-python:3.13
```

Run interactively:

```
docker run --rm -it ghcr.io/0xalexb/ralphex-python:3.13 bash
```

Use as a base for your own image:

```dockerfile
FROM ghcr.io/0xalexb/ralphex-python:3.13
COPY . /workspace
RUN uv sync
```

## Build

Build all variants:

```
make build
```

Build a single variant:

```
make build-one PYTHON_VERSION=3.13
```

Push all variants:

```
make push
```

Override the UV version:

```
make build UV_VERSION=0.9.0
```

Override the ruff version:

```
make build RUFF_VERSION=0.14.0
```

Override the image name:

```
make build DOCKER_IMAGE=my-registry/my-image
```
