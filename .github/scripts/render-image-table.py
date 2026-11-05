#!/usr/bin/env python3
"""Render the image table in README.md from images/*/Dockerfile.

The description is taken from the mandatory
org.opencontainers.image.description label of each Dockerfile.

Usage:
  render-image-table.py          # update README.md in place
  render-image-table.py --check  # exit 1 if README.md is outdated
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
README = ROOT / "README.md"
START = "<!-- images-table:start -->"
END = "<!-- images-table:end -->"
GHCR_OWNER = "tuxpeople"
DOCKERHUB_USER = "tdeutsch"

LABEL_RE = re.compile(r'org\.opencontainers\.image\.description="([^"]*)"')


def description(dockerfile):
    # Multi-stage builds: the label of the last (runtime) stage wins
    labels = LABEL_RE.findall(dockerfile.read_text())
    if not labels:
        sys.exit(f"ERROR: {dockerfile} has no org.opencontainers.image.description label")
    return labels[-1]


def render_table():
    rows = [
        "| Image | Description | Registries |",
        "|-------|-------------|------------|",
    ]
    for dockerfile in sorted(ROOT.glob("images/*/Dockerfile")):
        name = dockerfile.parent.name
        registries = (
            f"[GHCR](https://ghcr.io/{GHCR_OWNER}/{name}) • "
            f"[Docker Hub](https://hub.docker.com/r/{DOCKERHUB_USER}/{name})"
        )
        rows.append(f"| [{name}](./images/{name}) | {description(dockerfile)} | {registries} |")
    return "\n".join(rows)


def main():
    readme = README.read_text()
    if START not in readme or END not in readme:
        sys.exit(f"ERROR: markers {START} / {END} not found in README.md")
    before, rest = readme.split(START, 1)
    _, after = rest.split(END, 1)
    rendered = f"{before}{START}\n{render_table()}\n{END}{after}"

    if "--check" in sys.argv[1:]:
        if rendered != readme:
            print("README.md image table is outdated, run: python3 .github/scripts/render-image-table.py")
            sys.exit(1)
        print("README.md image table is up to date")
        return

    README.write_text(rendered)


if __name__ == "__main__":
    main()
