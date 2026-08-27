#!/usr/bin/env bash
set -euo pipefail

if command -v container-use >/dev/null 2>&1; then
  echo "container-use is already installed. To update, follow its instructions."
  return 0
fi

curl -fsSL https://raw.githubusercontent.com/dagger/container-use/main/install.sh | bash

echo "container-use installed succesfully."
