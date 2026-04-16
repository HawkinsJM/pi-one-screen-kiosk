#!/bin/bash
# kiosk-update.sh — pulls the latest sites from GitHub, then restarts the kiosk.
# Run this whenever you want to pick up new content from the repo.

set -e

REPO_DIR=/home/jeff/softsystems

echo "Pulling latest from GitHub..."
cd "$REPO_DIR"
git pull

echo "Restarting kiosk..."
sudo systemctl restart kiosk

echo "Done."
