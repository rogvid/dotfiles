if ! command -v mise >/dev/null 2>&1; then
	echo "Mise is not installed"
	exit;
fi

mise use -g go
mise use -g uv
mise use -g node
mise use -g lazygit
mise use -g lazydocker
mise use -g gum
mise use -g glow
mise use -g yq
mise use -g k3s
mise use -g duf
mise use -g ctop
mise use -g btop
mise use -g balena
mise use -g azure
mise use -g aws-cli
mise use -g ruff
mise use -g fd
mise use -g bat
mise use -g ripgrep
mise use -g fzf
mise use -g sops
mise use -g restic
mise use -g bitwarden
