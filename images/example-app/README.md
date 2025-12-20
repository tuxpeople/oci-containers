# example-app

A simple example container demonstrating the OCI containers repository structure.

## Usage

```bash
docker run -it ghcr.io/tuxpeople/example-app:latest
```

## Features

- Alpine Linux base
- Non-root user
- Health checks
- Minimal footprint

## Configuration

No configuration required for this example.

## Build Locally

```bash
docker build -t example-app:test ./images/example-app
```

## Testing

Optional: Add Goss tests by creating a `goss.yaml` file in this directory.
