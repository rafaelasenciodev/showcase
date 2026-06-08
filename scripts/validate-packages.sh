#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for pkg in "$ROOT"/Packages/*/; do
  name="$(basename "$pkg")"
  echo "Validating $name..."
  (cd "$pkg" && swift package describe > /dev/null)
done

echo "All packages validated."
