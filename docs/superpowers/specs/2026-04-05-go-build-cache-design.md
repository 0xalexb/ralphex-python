# Go Build Cache Optimization

## Problem

The `build-go` CI job takes ~8 minutes because every run re-downloads Go binaries, recompiles Go dev tools from source, and reinstalls npm packages — even when nothing has changed. No Docker layer caching is configured.

## Solution

Add GitHub Actions cache (`type=gha`) to the `build-go` job in `.github/workflows/build-publish.yml`.

## Change

In the `build-go` job's "Build and push" step, add:

```yaml
cache-from: type=gha,scope=go
cache-to: type=gha,scope=go,mode=max
```

### Parameters

- **`scope=go`**: Isolates the Go cache from Python/PHP builds (avoids collisions if caching is added to those later).
- **`mode=max`**: Caches all intermediate layers, not just the final image. This ensures the Go binary download and Go tools compilation layers are cached independently.

## File to Modify

- `.github/workflows/build-publish.yml` — `build-go` job, "Build and push" step (lines ~290-301)

## Expected Impact

| Scenario | Before | After |
|----------|--------|-------|
| No version changes | ~8min | ~30-60s |
| Only Claude Code/Codex update | ~8min | ~2-3min |
| Go version update | ~8min | ~6-7min |
| Ralphex base update | ~8min | ~8min (no change) |

## Verification

1. Push the change to the `fix/go-cache` branch.
2. Trigger a build (manual dispatch or release).
3. First run: expect similar ~8min (cold cache).
4. Second run with no version changes: expect significant drop (~1min).
5. Confirm in the job logs that `importing cache manifest from gha:go` appears.

## Constraints

- 10GB shared cache limit across the entire repo. The Go image is ~1-2GB of layers, so multi-platform (amd64+arm64) will use ~2-4GB. Leaves room for other caches if needed later.
- No changes to the Makefile or Dockerfile.
