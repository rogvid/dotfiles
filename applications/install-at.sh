#!/usr/bin/env bash
set -euo pipefail

echo "Installing 'at' command for scheduled tasks..."

if command -v apt > /dev/null 2>&1; then
    sudo apt update && sudo apt install -y at
elif command -v dnf > /dev/null 2>&1; then
    sudo dnf install -y at
elif command -v pacman > /dev/null 2>&1; then
    sudo pacman -S --noconfirm at
else
    echo "Error: Unsupported package manager. Please install 'at' manually."
    exit 1
fi

echo "Enabling and starting atd service..."
sudo systemctl enable --now atd

echo "'at' command installed and atd service is running."
