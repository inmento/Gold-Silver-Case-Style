#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VERSION=$(sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ROOT/manifest.json" | head -n 1)
if [[ -z "$VERSION" ]]; then
  echo "Could not read a version from manifest.json" >&2
  exit 1
fi
PACKAGE_NAME="Gold-Silver-Case-Style"
OUT_DIR="$ROOT/dist"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$OUT_DIR" "$STAGE/$PACKAGE_NAME"
cp "$ROOT/main.lua" "$ROOT/manifest.json" "$ROOT/README.md" "$ROOT/CHANGELOG.md" "$ROOT/LICENSE" "$STAGE/$PACKAGE_NAME/"
(
  cd "$STAGE"
  zip -qr "$OUT_DIR/${PACKAGE_NAME}-${VERSION}.zip" "$PACKAGE_NAME"
)
printf '%s\n' "$OUT_DIR/${PACKAGE_NAME}-${VERSION}.zip"
