# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker image repository that builds three images extending the [ralphex](https://github.com/umputun/ralphex) family of Alpine-based dev images:

- **ralphex-python** (`ghcr.io/0xalexb/ralphex-python`) - Multi-platform (linux/amd64, linux/arm64). Extends ralphex with jq, yq, UV, ruff, Claude Code, Codex, Pi, and multiple Python versions (3.11, 3.12, 3.13)
- **ralphex-go** (`ghcr.io/0xalexb/ralphex-go`) - Multi-platform (linux/amd64, linux/arm64). Extends ralphex with Go (from official binaries), golangci-lint, moq, goimports, gci, jq, yq, Claude Code, Codex, and Pi
- **ralphex-php** (`ghcr.io/0xalexb/ralphex-php`) - Multi-platform (linux/amd64, linux/arm64). Extends ralphex with jq, yq, Composer, PHPStan, Claude Code, Codex, Pi, and multiple PHP versions (8.3, 8.4, 8.5)

## Build Commands

```bash
make build                              # Build for native platform (local dev)
make build-python                       # Build all Python variants (native platform)
make build-one PYTHON_VERSION=3.13      # Build a single Python variant (native platform)
make build-go                           # Build Go image (native platform)
make build-php                          # Build all PHP variants (native platform)
make build-one-php PHP_VERSION=8.5      # Build a single PHP variant (native platform)
make push                               # Build multi-platform (amd64+arm64) + push to GHCR
make push PLATFORMS=linux/amd64         # Override platforms for push
make setup-buildx                       # Create docker-container buildx builder

# Override defaults
make build-python UV_VERSION=0.9.0             # Custom UV version (default: 0.10.6)
make build-python RUFF_VERSION=0.14.0          # Custom ruff version (default: 0.15.3)
make build-python RALPHEX_VERSION=0.5.2        # Pin upstream ralphex version
make build-go GO_VERSION=1.26.1                  # Custom Go version (default: 1.26.1)
make build-go RALPHEX_VERSION=0.5.2             # Pin upstream ralphex version for Go
make build-php RALPHEX_VERSION=0.5.2            # Pin upstream ralphex version for PHP
make build CLAUDE_CODE_VERSION=1.0.0            # Pin Claude Code version (default: latest)
make build CODEX_VERSION=0.1.0                  # Pin Codex version (default: latest)
make build PI_VERSION=0.72.1                    # Pin Pi version (default: latest)
make build VERSION=1.0.0 RALPHEX_VERSION=0.5.2  # Fully-pinned tags
```

There are no tests or linters in this repo. Verification is done by each Dockerfile's final `RUN` step which checks tool versions.

## Architecture

- **docker-python/Dockerfile** - Multi-stage build: copies UV binaries from `ghcr.io/astral-sh/uv`, installs a Python version via UV, installs ruff globally via `uv tool install`, installs Claude Code, Codex, and Pi via npm. Build args: `UV_VERSION`, `RUFF_VERSION`, `RALPHEX_VERSION`, `PYTHON_VERSION`, `CLAUDE_CODE_VERSION`, `CODEX_VERSION`, `PI_VERSION`.
- **docker-go/Dockerfile** - Extends `ghcr.io/umputun/ralphex`, installs Go from official binaries with arch detection, installs Go dev tools (golangci-lint, moq, goimports), installs jq via apk, installs Claude Code, Codex, and Pi via npm. Build args: `RALPHEX_VERSION`, `GO_VERSION`, `CLAUDE_CODE_VERSION`, `CODEX_VERSION`, `PI_VERSION`.
- **docker-php/Dockerfile** - Extends `ghcr.io/umputun/ralphex`, installs PHP via apk (versioned packages), Composer via installer, PHPStan via PHAR download, installs Claude Code, Codex, and Pi via npm. Build args: `RALPHEX_VERSION`, `PHP_VERSION`, `COMPOSER_VERSION`, `PHPSTAN_VERSION`, `CLAUDE_CODE_VERSION`, `CODEX_VERSION`, `PI_VERSION`.
- **Makefile** - Builds all three images using `docker buildx`. `build` targets use native platform with `--load` for local dev; `push` targets build multi-platform (`linux/amd64,linux/arm64`) with `--push`. `setup-buildx` creates a `docker-container` driver builder. Python: loops over `PYTHON_VERSIONS := 3.11 3.12 3.13`. Go: single build. PHP: loops over `PHP_VERSIONS := 8.3 8.4 8.5`. All use `RALPHEX_VERSION` for the upstream version. Targets: `build-python`/`push-python`, `build-go`/`push-go`, `build-php`/`push-php`, `build`/`push` (all).
- **.github/workflows/build-publish.yml** - Triggered only by pushing a `v*` tag (`on: push: tags`). The repo version comes from the pushed tag; all tool versions (ralphex, Claude Code, Codex, UV, Composer, PHPStan, Go, Pi) are resolved to their latest upstream release. It then builds each image (Python and PHP variants via matrix, plus Go) for linux/amd64 and linux/arm64 on **native runners** (amd64 on `ubuntu-latest`, arm64 on `ubuntu-24.04-arm`) — no QEMU emulation. Each arch is pushed by digest, and a per-image `merge-*` job combines the digests into a multi-arch manifest with the final tags. Native builds fixed the constant multi-arch failures where npm crashed with SIGILL ("Illegal instruction", exit 132) under QEMU.

## Tag Scheme

**Python**: `<repo_ver>-r<ralphex_ver>-py<python_ver>` (e.g., `1.0.0-r0.5.2-py3.13`). Floating variants: `r<ralphex>-py<python>`, `py<python>`, `latest` (points to the highest Python version, currently 3.13).

**Go**: `<repo_ver>-r<ralphex_go_ver>` (e.g., `1.0.0-r0.1.0`). Floating variants: `r<ralphex_go>`, `latest`.

**PHP**: `<repo_ver>-r<ralphex_ver>-php<php_ver>` (e.g., `1.0.0-r0.5.2-php8.5`). Floating variants: `r<ralphex>-php<php_ver>`, `php<php_ver>`, `latest` (points to the highest PHP version, currently 8.5).

## Conventions

- GitHub Actions use pinned commit SHAs for all third-party actions.
- Builds are tag-triggered only: push a `v*` tag to build and publish. No scheduled/cron builds. The default `GITHUB_TOKEN` (with `packages: write`) is the only secret needed.
- Completed plans go in `docs/plans/completed/`.
- UV and ruff default versions are set as `ARG` defaults in `docker-python/Dockerfile`; update them there for version bumps.
- Composer and PHPStan default versions are set as `ARG` defaults in `docker-php/Dockerfile`; update them there for version bumps.
- Go default version is set as `ARG` default in `docker-go/Dockerfile`; update it there for version bumps.
- Claude Code, Codex, and Pi default to `latest` in all Dockerfiles; specific versions can be pinned via build args for local builds.
