# My Dotfiles

This repository contains the configurations for tools that I use on a daily basis. I use this dotfiles repository in combination with my ansible zero-touch provisioning.

## Requirements

Before setting up a new dev environment make sure the following is present:

- `git`
- `curl`

# Instructions for quickly setting up configurations on a new machine

The recommended setup is to run the init script from git:

```bash
curl -Lks github.com/rogvid/dotfiles/setup.sh | /bin/bash
```

## Working on this repo

Tooling is pinned in `mise.toml`, so the git hooks and CI run identical versions.

```bash
mise install     # fetch the pinned tools
mise run hooks   # install the prek hooks into .git/hooks (once per clone)
mise run lint    # everything CI runs, against every file
mise run secrets # scan the full git history for secrets
mise run test    # the repo's own tests
```

Secrets are kept out by four independent layers, each verified to fire:

1. `.gitignore` refuses key material, `.env` files, and `*.bak` backups at `git add` time.
2. `gitleaks` scans staged changes on every commit.
3. `detect-private-key` catches key blocks that gitleaks' rules might miss.
4. CI re-scans the **whole history** on every push and weekly, since rules improve over time.

Anything that genuinely must be versioned goes in `secrets.yaml`, encrypted with sops (see `.sops.yaml`).

`mise run lint` enforces shellcheck at warning level.
Two files are exempt: `zsh/` (shellcheck has no zsh dialect) and the vendored `scripts/.local/bin/cht.sh`.
