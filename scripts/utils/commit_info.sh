#!/bin/bash
echo "PATH:$(pwd)"
echo "BRANCH:$(git branch --show-current)"
PATCH_FILE=$(git format-patch HEAD^)
echo "PATCH_FILE=${PATCH_FILE}"
