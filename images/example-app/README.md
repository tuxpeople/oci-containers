# example-app

A simple example container demonstrating the OCI containers repository structure.

## Usage

```bash
# Run with shell (interactive)
docker run -it --rm ghcr.io/tuxpeople/example-app:latest /bin/bash

# Run as daemon (keeps running)
docker run -d ghcr.io/tuxpeople/example-app:latest
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
