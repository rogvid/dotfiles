#!/usr/bin/env bash
# Zero-touch provisioning for these dotfiles.
#
#   curl -fsSL https://raw.githubusercontent.com/rogvid/dotfiles/main/ztp.sh | bash
#
# Asks where to clone the repo and which profile this machine gets, then
# installs mise, clones, links everything and runs `mise bootstrap`. Every step
# checks before it acts, so re-running it on a provisioned machine is safe and
# is also how to move the repo or change the profile.
#
# Answer the prompts up front to run unattended:
#
#   curl -fsSL .../ztp.sh | bash -s -- --dir ~/src/dotfiles --profile headless --yes
set -euo pipefail

REPO_DEFAULT="https://github.com/rogvid/dotfiles.git"
LINK="$HOME/.dotfiles"
MISE_DIR="$HOME/.config/mise"

usage() {
  cat <<EOF
Usage: ztp.sh [options] [-- <mise bootstrap options>]

  --dir PATH         where to clone the repo      (default: ~/.dotfiles)
  --profile NAME     desktop or headless          (default: headless on WSL, else desktop)
  --repo URL         repository to clone          (default: $REPO_DEFAULT)
  --no-gh-login      skip the GitHub login offer
  -y, --yes          no prompts; take the defaults for anything not given
  -h, --help         show this help

Options after -- go to \`mise bootstrap\`, e.g. -- --skip packages,services

Profiles:
  desktop   everything, plus kanata, Obsidian, LocalSend, restic units, at/atd
  headless  the terminal environment only - for WSL, servers and containers
EOF
}

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

YES=0
# Prompts read the terminal, not stdin: under `curl | bash` stdin is the script.
interactive() { [[ $YES -eq 0 ]] && { : </dev/tty; } 2>/dev/null; }

# ask <question> <default>
ask() {
  local reply=""
  if interactive; then
    printf '%s [%s]: ' "$1" "$2" >/dev/tty
    IFS= read -r reply </dev/tty || true
  fi
  printf '%s' "${reply:-$2}"
}

# confirm <question> <y|n>
confirm() {
  local reply
  reply=$(ask "$1 (y/n)" "$2")
  [[ $reply == [yY]* ]]
}

expand_home() { printf '%s' "${1/#\~/$HOME}"; }

is_wsl() {
  [[ -n ${WSL_DISTRO_NAME:-} ]] || grep -qi microsoft /proc/version 2>/dev/null
}

ensure_git() {
  command -v git >/dev/null && return
  command -v apt-get >/dev/null || die "git is required; install it and re-run"
  confirm "git is missing. Install it with apt?" y || die "git is required"
  sudo apt-get update -qq && sudo apt-get install -y -qq git
}

ensure_mise() {
  export PATH="$HOME/.local/bin:$PATH"
  if command -v mise >/dev/null; then
    say "mise $(mise --version 2>/dev/null | cut -d' ' -f1) already installed"
    return
  fi
  say "Installing mise"
  curl -fsSL https://mise.run | sh
}

# Most tools come from GitHub releases; anonymously, installing them all runs
# into the API rate limit. mise reuses gh's token.
offer_gh_login() {
  [[ -n ${GITHUB_TOKEN:-} ]] && return
  mise x gh@latest -- gh auth status >/dev/null 2>&1 && return
  if ! interactive; then
    warn "not logged in to GitHub and no GITHUB_TOKEN: tool installs may hit the API rate limit"
    return
  fi
  confirm "Log in to GitHub? It avoids API rate limits while installing tools" y || return 0
  mise x gh@latest -- gh auth login </dev/tty
}

clone_repo() {
  local dir=$1 repo=$2
  if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    say "Using the existing checkout at $dir"
    return
  fi
  if [[ -e $dir && -n $(ls -A "$dir" 2>/dev/null) ]]; then
    die "$dir exists and is not a git checkout"
  fi
  say "Cloning $repo to $dir"
  mkdir -p "$(dirname "$dir")"
  git clone "$repo" "$dir"
}

# Every [dotfiles] source is ~/.dotfiles/..., so this one link is what lets the
# repo live anywhere.
link_repo() {
  local dir=$1 real
  real=$(cd "$dir" && pwd -P)
  if [[ -L $LINK ]]; then
    [[ $(readlink -f "$LINK") == "$real" ]] && return
    confirm "$LINK points at $(readlink "$LINK"). Repoint it to $real?" y ||
      die "$LINK must point at the repo"
  elif [[ -e $LINK ]]; then
    [[ $(cd "$LINK" && pwd -P) == "$real" ]] && return
    die "$LINK exists and is not this repo; move it aside and re-run"
  fi
  say "Linking $LINK -> $real"
  ln -sfn "$real" "$LINK"
}

# Links from stow or an older layout can reach the repo by another path. mise
# counts them as applied because they resolve to the right file, but they break
# the moment the repo moves. Replace each with a link through ~/.dotfiles; only
# symlinks that already resolve to the exact source are touched.
repoint_old_links() {
  local env=$1 target mode source t s count=0
  while read -r target mode source _; do
    [[ $mode == symlink ]] || continue
    t=$(expand_home "$target")
    s=$(expand_home "$source")
    [[ -L $t && $(readlink "$t") != "$s" ]] || continue
    [[ $(readlink -f "$t") == "$(readlink -f "$s")" ]] || continue
    rm "$t"
    count=$((count + 1))
  done < <(MISE_CONFIG_DIR="$LINK/mise/.config/mise" MISE_ENV=$env \
    mise bootstrap dotfiles status 2>/dev/null)
  if [[ $count -gt 0 ]]; then
    say "Repointing $count existing links through $LINK"
  fi
}

# mise refuses to replace a real file with a link, so move aside any global
# config that predates this repo.
back_up_mise_config() {
  local f stamp
  stamp=$(date +%Y%m%d%H%M%S)
  for f in "$MISE_DIR/config.toml" "$MISE_DIR/config.desktop.toml"; do
    [[ -e $f && ! -L $f ]] || continue
    confirm "$f is not managed by this repo. Move it to $f.ztp-$stamp?" y ||
      die "cannot link $f while it exists"
    mv "$f" "$f.ztp-$stamp"
  done
}

write_profile() {
  local profile=$1
  mkdir -p "$MISE_DIR"
  [[ -L $MISE_DIR/miserc.toml ]] && rm "$MISE_DIR/miserc.toml"
  say "Recording profile '$profile' in $MISE_DIR/miserc.toml"
  {
    echo "# Written by ztp.sh: this machine's profile. Re-run ztp.sh to change it."
    if [[ $profile == desktop ]]; then
      echo 'env = ["desktop"]'
    else
      echo 'env = []'
    fi
  } >"$MISE_DIR/miserc.toml"
}

main() {
  local dir=${DOTFILES_DIR:-} profile=${DOTFILES_PROFILE:-} repo=${DOTFILES_REPO:-$REPO_DEFAULT}
  local gh_login=1 default_profile=desktop
  local -a bootstrap_args=()

  while [[ $# -gt 0 ]]; do
    case $1 in
      --dir) dir=${2:?--dir needs a path}; shift 2 ;;
      --profile) profile=${2:?--profile needs a name}; shift 2 ;;
      --repo) repo=${2:?--repo needs a URL}; shift 2 ;;
      --no-gh-login) gh_login=0; shift ;;
      -y | --yes) YES=1; shift ;;
      -h | --help) usage; exit 0 ;;
      --) shift; bootstrap_args=("$@"); break ;;
      *) usage >&2; die "unknown option: $1" ;;
    esac
  done

  is_wsl && default_profile=headless
  if [[ -z $dir ]]; then
    local default_dir=$LINK
    [[ -L $LINK ]] && default_dir=$(readlink -f "$LINK")
    dir=$(ask "Clone the dotfiles to" "$default_dir")
  fi
  dir=$(expand_home "$dir")
  [[ -n $profile ]] || profile=$(ask "Profile: desktop or headless" "$default_profile")
  [[ $profile == desktop || $profile == headless ]] || die "unknown profile: $profile"

  ensure_git
  ensure_mise
  [[ $gh_login -eq 1 ]] && offer_gh_login
  clone_repo "$dir" "$repo"
  link_repo "$dir"
  back_up_mise_config
  write_profile "$profile"

  local env=""
  [[ $profile == desktop ]] && env=desktop
  repoint_old_links "$env"

  # The global config does not exist until the dotfiles step links it, so this
  # first apply reads the config straight from the repo.
  say "Linking dotfiles"
  MISE_CONFIG_DIR="$LINK/mise/.config/mise" MISE_ENV=$env \
    mise bootstrap dotfiles apply --yes

  # Trust the real path: that is what a shell entering the repo resolves.
  mise trust --quiet "$(readlink -f "$LINK")/mise.toml"

  # From here on it is the steady state: the linked config plus miserc.toml.
  say "Running mise bootstrap (packages and services may ask for sudo)"
  if { : </dev/tty; } 2>/dev/null; then
    mise bootstrap --yes "${bootstrap_args[@]}" </dev/tty
  else
    mise bootstrap --yes "${bootstrap_args[@]}"
  fi

  say "Done. Open a new shell to pick up the linked zsh config."
  printf '    %-34s %s\n' "mise config ls" "which config files this machine loads" \
    "cd ~/.dotfiles && mise run drift" "check the machine still matches the repo"
}

main "$@"
