#!/bin/bash
set -e

PACKAGE_DIR=$1
FORCE=$2

if [ -z "$PACKAGE_DIR" ]; then
  echo "Usage: $0 <package-dir> [force]"
  exit 1
fi

PUBSPEC_PATH="${PACKAGE_DIR}/pubspec.yaml"
if [ ! -f "$PUBSPEC_PATH" ]; then
  echo "Error: $PUBSPEC_PATH not found."
  exit 1
fi

# Read version and package name using yq
# Assumes standard yq binary is available (default on GitHub Actions ubuntu runner)
VERSION=$(yq -r '.version' "$PUBSPEC_PATH")
PACKAGE_NAME=$(yq -r '.name' "$PUBSPEC_PATH")

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  echo "Error: Could not extract version from $PUBSPEC_PATH"
  exit 1
fi

TAG_NAME="${PACKAGE_DIR}-v${VERSION}"

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

if [ "$FORCE" = "true" ]; then
  echo "Force flag is set. Checking for existing tag..."

  PUB_API_URL="https://pub.dev/api/packages/${PACKAGE_NAME}/versions/${VERSION}"
  echo "Checking pub.dev: $PUB_API_URL"

  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PUB_API_URL")

  if [ "$HTTP_STATUS" = "200" ]; then
    echo "Error: Version $VERSION of package $PACKAGE_NAME is already published on pub.dev."
    echo "Cannot force delete a published tag."
    exit 1
  fi

  if git ls-remote --tags origin | awk '{print $2}' | grep -q "^refs/tags/$TAG_NAME$"; then
    echo "Tag $TAG_NAME exists on remote. Deleting..."
    git push origin --delete "$TAG_NAME"
  fi
  if git tag -l | grep -q "^$TAG_NAME$"; then
    echo "Tag $TAG_NAME exists locally. Deleting..."
    git tag -d "$TAG_NAME"
  fi
fi

echo "Creating tag: $TAG_NAME"
git tag "$TAG_NAME"
git push origin "$TAG_NAME"
