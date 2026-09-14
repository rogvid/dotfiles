# My Dotfiles

This repository contains the configurations for tools that I use on a daily basis.
Everything is declared in `mise/.config/mise/config.toml` and applied by `mise bootstrap` - there is no init script, no GNU stow, and no ansible.

## Setting up a new machine

Only `git`, `curl` and `sudo` need to be present.

```bash
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
mise x gh -- gh auth login
git clone https://github.com/rogvid/dotfiles.git ~/asgard/personal/dotfiles
MISE_CONFIG_DIR=~/asgard/personal/dotfiles/mise/.config/mise mise bootstrap --yes
```

The config lives inside this repo, so the repo has to be cloned before mise can read it.
`MISE_CONFIG_DIR` is only needed for that first run: it links `~/.config/mise/` back into the repo, and from then on a plain `mise bootstrap` works.
The same commands set up WSL - see [Desktop and WSL](#desktop-and-wsl).
The anonymous https clone matches the `git@` URL in `[bootstrap.repos]`; switch the remote with `git remote set-url origin git@github.com:rogvid/dotfiles.git` once an SSH key is set up for pushing.

`gh auth login` matters even though the repo is public: mise reuses the `gh` token, and without it the GitHub-hosted tools in `[tools]` exhaust the anonymous API rate limit.
Do not use `mise use -g gh` for this step - it writes a real `~/.config/mise/config.toml`, which then blocks the symlink.

`mise bootstrap` installs the OS packages in `[bootstrap.packages]` and starts `[bootstrap.services]` (both prompt for `sudo`), symlinks every path in `[dotfiles]`, and installs every tool in `[tools]`.
Add `--dry-run` first to see what it would do.

## Desktop and WSL

`mise/.config/mise/` holds three files:

| File | Loaded | Holds |
| --- | --- | --- |
| `config.toml` | Everywhere | Shell, editor, git, CLI tools, scripts - everything a terminal needs |
| `config.desktop.toml` | Everywhere except WSL | kanata, Obsidian and LocalSend with their launchers, restic units, `at` and `atd` |
| `miserc.toml` | First, before either | Selects the `desktop` profile unless `WSL_DISTRO_NAME` is set, which WSL does for everything it starts |

So the WSL machine skips what needs a physical keyboard, a Linux desktop or a running systemd, with no flag to remember.
`mise config ls` shows which files a machine loaded.

## Day to day

Every managed path is a symlink into this repo, so editing a config anywhere is editing the repo: the change shows up in `git status` here, ready to commit.

| To | Do |
| --- | --- |
| Add a tool | `mise use -g <tool>` - it writes through the symlink into `config.toml`; move the line to `config.desktop.toml` if WSL should not get it |
| Add a script | Put it in `scripts/.local/bin`, `git add` it, then `mise bootstrap dotfiles apply` |
| Manage a new config file | Move it into a package directory here, add a `[dotfiles]` entry, then `mise bootstrap dotfiles apply` |
| Add an OS package or service | Add it to `[bootstrap.packages]` or `[bootstrap.services]`, then `mise bootstrap --only packages,services` |
| Upgrade tools | `mise upgrade` - Obsidian is pinned (see the comment in `config.desktop.toml`), so bump its version by hand |
| Bring a machine up to date | `mise bootstrap` - it fast-forwards this checkout to `main` first, then applies |

`mise bootstrap` refuses to run while this checkout has uncommitted changes, because `[bootstrap.repos]` will not touch a dirty repo.
Commit first, or add `--skip repos` while you are mid-edit.

A desktop app also needs a launcher: copy one of the templates in `desktop/` and add a `mode = "template"` entry to `[dotfiles]` in `config.desktop.toml`.

## Drift

Some changes never reach `git status`: an app replaces its symlink with a real file, a new script or `[dotfiles]` entry has not been applied yet, or a declared tool, package or service is not installed.
`mise run drift` checks all of those and prints only what is wrong, with the command that fixes it.

It also runs by itself whenever a shell enters this repo (the `enter` hook in `mise.toml`), and stays silent when the machine matches.
It takes about 150 ms and never touches the network.

```text
drift: packages - fix with: mise bootstrap --only packages
  apt  at                       missing
```

A link that became a real file needs `mise bootstrap dotfiles apply --force`, which discards the app's copy - diff it against the repo first.

This is the part stow never had.
When this repo was migrated, the status report found ten packages that had silently never been linked on the main machine, a `lazygit` config under a filename lazygit does not read, and two directories whose contents would have been destroyed by a naive symlink.

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
