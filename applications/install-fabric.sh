#!/usr/bin/env bash
set -euo pipefail

# Import the utils
source "${HOME}/.local/scripts/utils.sh"

PACKAGE_NAME="fabric"
URL="https://github.com/danielmiessler/fabric/releases/download/v1.4.202/fabric-linux-amd64"

# Ensure install dir exists
ensure_local_bin

# Exit if already installed
if check_installed "${PACKAGE_NAME}"; then
  exit 1
fi

# Get target path
INSTALL_PATH=$(local_bin_path "${PACKAGE_NAME}")
echo "Attempting to download the application ${PACKAGE_NAME} from ${URL}"
echo "Will install ${PACKAGE_NAME} to ${INSTALL_PATH}"

download_bin_to "${URL}" "${INSTALL_PATH}"


