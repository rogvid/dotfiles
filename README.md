# My Dotfiles

This repository contains the configurations for tools that I use on a daily basis.
Everything is declared in `mise/.config/mise/` and applied by `mise bootstrap`; `ztp.sh` sets up a new machine with one command.

## Setting up a new machine

```bash
curl -fsSL https://raw.githubusercontent.com/rogvid/dotfiles/main/ztp.sh | bash
```

`ztp.sh` asks two things, then does the rest:

1. **Where to clone the repo** - anywhere; the default is `~/personal/projects/dotfiles`.
2. **Which profile** - `desktop`, or `headless` for WSL, servers and containers. It defaults to `headless` when it detects WSL.

It installs git (via apt, if missing) and mise, offers a GitHub login, clones the repo, and runs `mise bootstrap`, which asks for `sudo` for OS packages and services.
The clone is a `git-wt` project: `.bare` holds git's data, `.git` points at it, and every branch gets a worktree folder next to them, the main branch's being `main/`.
Re-running it on a machine with an old plain clone offers to convert that clone with `git-wt convert`.
Only `curl` needs to be present.

To skip the prompts, answer them up front:

```bash
curl -fsSL https://raw.githubusercontent.com/rogvid/dotfiles/main/ztp.sh | bash -s -- --dir ~/src/dotfiles --profile headless --yes
```

`ztp.sh --help` lists every option; anything after `--` goes to `mise bootstrap` (for example `-- --skip packages,services`).
The script is safe to re-run, and re-running it is how to move the repo or switch a machine's profile.

The GitHub login matters even though the repo is public: mise reuses the `gh` token, and without it the GitHub-hosted tools exhaust the anonymous API rate limit.
Clones use https; switch with `git remote set-url origin git@github.com:rogvid/dotfiles.git` once an SSH key is set up for pushing.

## How it fits together

- **`~/.dotfiles`** is a symlink to the main worktree of wherever the repo was cloned, `<dir>/main`. Every `[dotfiles]` source goes through it, so moving the repo means re-running `ztp.sh --dir <new path>`.
- **`mise/.config/mise/config.toml`** is loaded on every machine: shell, editor, git, CLI tools, scripts - everything a terminal needs.
- **`mise/.config/mise/config.desktop.toml`** is loaded by the `desktop` profile only: kanata, Obsidian and LocalSend with their launchers, the restic units, and `at` with `atd`. WSL gets none of it - no keyboard to remap, no Linux GUI apps, and possibly no systemd.
- **`~/.config/mise/miserc.toml`** is not in the repo. `ztp.sh` writes it to record the machine's profile.

`mise config ls` shows which config files a machine loads.

## Day to day

Every managed path is a symlink into this repo, so editing a config anywhere is editing the repo: the change shows up in `git status` here, ready to commit.

| To | Do |
| --- | --- |
| Add a tool | `mise use -g <tool>` - it writes through the symlink into `config.toml`; move the line to `config.desktop.toml` if WSL should not get it |
| Add a script | Put it in `scripts/.local/bin`, `git add` it, then `mise bootstrap dotfiles apply` |
| Manage a new config file | Move it into a package directory here, add a `[dotfiles]` entry, then `mise bootstrap dotfiles apply` |
| Add an OS package or service | Add it to `[bootstrap.packages]` or `[bootstrap.services]`, then `mise bootstrap --only packages,services` |
| Upgrade tools | `mise upgrade` - Obsidian is pinned (see the comment in `config.desktop.toml`), so bump its version by hand |
| Bring a machine up to date | `git -C ~/.dotfiles pull`, then `mise bootstrap` |

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
