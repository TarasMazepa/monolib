#!/bin/bash
set -e

# Resolve repository root regardless of current working directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Generating monodoc.md in $REPO_ROOT..."
echo "dart \"$SCRIPT_DIR/generate-monodoc.dart\""

dart "$SCRIPT_DIR/generate-monodoc.dart"
