# syntax=docker/dockerfile:1

# Example: Simple Alpine-based debug container
# This shows the minimal structure for an image in this repo

# Base image - always use specific tags
FROM alpine:3.19

# Labels - required for OCI compliance
LABEL org.opencontainers.image.title="example-app"
LABEL org.opencontainers.image.description="Example application container"
LABEL org.opencontainers.image.vendor="tuxpeople"

# Install packages with pinned versions
RUN apk add --no-cache \
    bash~=5.2 \
    curl~=8.5 \
    vim~=9.0 \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Set working directory
WORKDIR /app

# Copy application files (if any)
# COPY --chown=appuser:appuser app/ /app/

# Switch to non-root user
USER appuser

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["sh", "-c", "echo 'healthy'"]

# Default command
CMD ["/bin/bash"]
