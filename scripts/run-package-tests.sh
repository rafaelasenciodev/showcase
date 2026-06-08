#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Packages with tests that run on the macOS host (Core targets have no UIKit dependency).
PACKAGES=(Domain Data Networking FeatureArticles FeatureFavorites FeatureSettings)

for name in "${PACKAGES[@]}"; do
  pkg="$ROOT/Packages/$name"
  echo "Testing $name..."
  (cd "$pkg" && swift test)
done

echo "All package tests passed."
