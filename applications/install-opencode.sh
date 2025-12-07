#!/usr/bin/env bash
set -euo pipefail

# Import the utils
source "${HOME}/.local/scripts/utils.sh"

PACKAGE_NAME="opencode"
URL="https://opencode.ai/install"

# Exit if already installed
if check_installed "${PACKAGE_NAME}"; then
  exit 1
fi

echo "Attempting to install the application ${PACKAGE_NAME} from ${URL}"
curl -fsSL "${URL}" | bash
