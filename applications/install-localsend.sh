#!/usr/bin/env bash
set -euo pipefail

if [ ! -d $HOME/applications ]; then
  echo "Creating a directory for appimages"
  mkdir $HOME/applications
fi

if [ -f $HOME/applications/localsend ]; then
  echo "Localsend is already installed. Do you want to update?"
  exit 0
fi

echo "Installing Localsend"
LATEST_VERSION=$(curl -s https://api.github.com/repos/localsend/localsend/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
curl -fssL https://github.com/localsend/localsend/releases/download/v${LATEST_VERSION}/LocalSend-${LATEST_VERSION}-linux-x86-64.AppImage -o ${HOME}/applications/localsend
chmod u+x $HOME/applications/localsend

# echo "Adding desktop entry"
