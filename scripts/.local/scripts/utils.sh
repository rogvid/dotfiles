#!/usr/bin/env bash
set -euo pipefail

# Ensure ~/.local/bin exists
ensure_local_bin() {
  local local_dir="${HOME}/.local/bin"
  mkdir -p "${local_dir}"
}

# Check if a binary is already installed in PATH
check_installed() {
  local name="$1"
  if command -v "${name}" >/dev/null 2>&1; then
    echo "${name} is already installed. To update, follow its instructions."
    return 0
  fi
  return 1
}

# Construct path to local binary
local_bin_path() {
  local name="$1"
  echo "${HOME}/.local/bin/${name}"
}

download_bin_to() {
  local url="$1"
  local dest="$2"

  curl -L ${url} >${dest}
  chmod +x ${dest}
  echo "Downloaded binary to ${dest}"
}
