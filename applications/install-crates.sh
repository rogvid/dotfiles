if ! command -v cargo >/dev/null 2>&1; then
	echo "Cargo is not installed"
	exit;
fi

cargo install atuin
cargo install starship
cargo install zoxide
cargo install eza
