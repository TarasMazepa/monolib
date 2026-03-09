#!/bin/bash
set -e

PACKAGE_DIR=$1
TAG_PREFIX="${PACKAGE_DIR}-v"

if [ -z "$PACKAGE_DIR" ]; then
  echo "Usage: $0 <package-dir>"
  # return 1 since we source or execute it
  exit 1
fi

PUBSPEC_PATH="${PACKAGE_DIR}/pubspec.yaml"

if [ ! -f "$PUBSPEC_PATH" ]; then
  echo "Error: $PUBSPEC_PATH not found in current commit."
  exit 1
fi

PREV_VERSION=""
if git rev-parse --verify HEAD^ >/dev/null 2>&1 && git ls-tree -r HEAD^ --name-only | grep -q "^${PUBSPEC_PATH}$"; then
  # Use yq to parse previous version from git show
  PREV_VERSION=$(git show "HEAD^:${PUBSPEC_PATH}" | yq -r '.version')
fi

# Use yq to parse current version
CURR_VERSION=$(yq -r '.version' "$PUBSPEC_PATH")

echo "Previous version: ${PREV_VERSION:-<none>}"
echo "Current version: $CURR_VERSION"

if [ "$PREV_VERSION" != "$CURR_VERSION" ] && [ -n "$CURR_VERSION" ] && [ "$CURR_VERSION" != "null" ]; then
  echo "Version changed. Calling create-tag.sh for directory: $PACKAGE_DIR"

  "$(dirname "$0")/create-tag.sh" "$PACKAGE_DIR"
else
  echo "Version did not change. No tag created."
fi
