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
