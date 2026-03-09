#!/bin/bash
set -e

TAG_NAME=$1
FORCE=$2

if [ -z "$TAG_NAME" ]; then
  echo "Usage: $0 <tag-name> [force]"
  exit 1
fi

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

if [ "$FORCE" = "true" ]; then
  echo "Force flag is set. Checking for existing tag..."

  # Extract directory and version from TAG_NAME (e.g., monolib-dart-v0.0.1)
  # Assuming format <directory>-v<version>
  PACKAGE_DIR=$(echo "$TAG_NAME" | sed -E 's/-v[0-9].*//')
  VERSION=$(echo "$TAG_NAME" | sed -E 's/.*-v([0-9].*)/\1/')

  # Package name replaces dashes with underscores
  PACKAGE_NAME=$(echo "$PACKAGE_DIR" | tr '-' '_')

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
