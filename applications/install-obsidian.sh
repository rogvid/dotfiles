#!/usr/bin/env bash
set -euo pipefail

AUTO_UPDATE=false

while getopts ":y" opt; do
  case "$opt" in
  y) AUTO_UPDATE=true ;;
  esac
done

if [ ! -d $HOME/applications ]; then
  echo "Creating a directory for appimages"
  mkdir $HOME/applications
fi

if [ -f $HOME/applications/obsidian ]; then
  echo "Obsidian is already installed."
  LATEST_OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
  CURRENT_OBSIDIAN_VERSION=
  if [[ "$AUTO_UPDATE" == true ]] || confirm "Update Obsidian?"; then
    echo "Check."
    ACTION=update
  fi
  exit 0
fi

if [ ! -f $HOME/.local/share/applications/icons/Obsidian.png ]; then
  echo "Icons have not been stowed! Stow icons before installing applications."
  exit 0
fi

echo "Installing Obsidian"
OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
NEW_APPIMAGE=$HOME/applications/Obsidian-${OBSIDIAN_VERSION}.AppImage
curl -fssL https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}.AppImage -o $NEW_APPIMAGE
chmod u+x $NEW_APPIMAGE
ln -sf "$NEW_APPIMAGE" "$HOME/.local/bin/obsidian"

if [ ! -f $HOME/.local/share/applications/Obsidian.desktop ]; then
  echo "Adding an Obsidian desktop entry"
  cat <<EOF >~/.local/share/applications/Obsidian.desktop
[Desktop Entry]
Version=1.0
Name=Obsidian
Comment=Personal Knowledge Management Software
Exec=$HOME/applications/obsidian --no-sandbox
Terminal=false
Type=Application
Icon=$HOME/.local/share/applications/icons/Obsidian.png
Categories=Office;Utility;
StartupNotify=false
EOF
  chmod +x $HOME/.local/share/applications/Obsidian.desktop
  update-desktop-database $HOME/.local/share/applications
fi
