#!/usr/bin/env bash
set -euo pipefail

# Colors for output (using $'...' so variables contain real escape characters)
readonly COLOR_RED=$'\033[0;31m'
readonly COLOR_GREEN=$'\033[0;32m'
readonly COLOR_BLUE=$'\033[0;34m'
readonly COLOR_YELLOW=$'\033[1;33m'
readonly COLOR_DIM=$'\033[2m'
readonly COLOR_BOLD=$'\033[1m'
readonly COLOR_RESET=$'\033[0m'

# Validate we're in a git repository
validate_in_git_repo() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${COLOR_RED}Error: Not in a git repository.${COLOR_RESET}" >&2
    echo "Run this command from within a git repository." >&2
    exit 1
  fi
}

# Validate that the git repo is in a 'projects/' folder structure
validate_projects_structure() {
  local repo_root
  repo_root="$(get_repo_root)"
  local parent_dir
  parent_dir="$(basename "$(dirname "${repo_root}")")"
  
  if [[ "${parent_dir}" != "projects" ]]; then
    echo -e "${COLOR_RED}Error: Git repository must be in a 'projects/' folder.${COLOR_RESET}" >&2
    echo "" >&2
    echo "Expected structure:" >&2
    echo "  ~/personal/projects/<repo>/" >&2
    echo "  ~/work/*/projects/<repo>/" >&2
    echo "" >&2
    echo -e "Current location: ${COLOR_YELLOW}${repo_root}${COLOR_RESET}" >&2
    echo "" >&2
    echo "Please move your repository to a 'projects/' folder or use regular 'git worktree' commands." >&2
    exit 1
  fi
}

# Get the absolute path to the git repository root
get_repo_root() {
  git rev-parse --show-toplevel
}

# Get the repository name (basename of repo root)
get_repo_name() {
  basename "$(get_repo_root)"
}

# Get the projects root directory (grandparent of repo)
get_projects_root() {
  local repo_root
  repo_root="$(get_repo_root)"
  # Parent is 'projects/', grandparent is what we want (e.g., ~/personal/)
  dirname "$(dirname "${repo_root}")"
}

# Get or create the worktrees root directory
get_worktrees_root() {
  local projects_root
  projects_root="$(get_projects_root)"
  local worktrees_root="${projects_root}/worktrees"
  
  # Create if it doesn't exist
  mkdir -p "${worktrees_root}"
  
  echo "${worktrees_root}"
}

# Get the main branch name.
# Priority:
#   1. git config worktree.mainBranch (explicit override)
#   2. Branch checked out in the primary worktree (the non-worktree checkout)
#   3. Fallback: first of main/master/trunk that exists
get_main_branch() {
  # 1. Explicit override via git config
  local configured
  configured="$(git config --get worktree.mainBranch 2>/dev/null)" || true
  if [[ -n "${configured}" ]]; then
    echo "${configured}"
    return 0
  fi

  # 2. Detect from the primary worktree's checked-out branch
  local git_common_dir primary_head
  git_common_dir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
  if [[ -f "${git_common_dir}/HEAD" ]]; then
    primary_head="$(cat "${git_common_dir}/HEAD")"
    if [[ "${primary_head}" =~ ^ref:\ refs/heads/(.+)$ ]]; then
      echo "${BASH_REMATCH[1]}"
      return 0
    fi
  fi

  # 3. Fallback: well-known branch names
  local branch
  for branch in main master trunk; do
    if git rev-parse --verify "${branch}" >/dev/null 2>&1; then
      echo "${branch}"
      return 0
    fi
  done

  echo -e "${COLOR_RED}Error: Could not detect main branch.${COLOR_RESET}" >&2
  exit 1
}

# Parse branch name to extract type and slug
# Examples:
#   feat/user-auth -> type: feat, slug: user-auth
#   fix/critical-bug -> type: fix, slug: critical-bug
#   simple-branch -> type: (empty), slug: simple-branch
parse_branch_name() {
  local branch="$1"
  local type=""
  local slug=""
  
  # Check if branch follows conventional format (type/name)
  if [[ "${branch}" =~ ^([a-zA-Z]+)/(.+)$ ]]; then
    type="${BASH_REMATCH[1]}"
    slug="${BASH_REMATCH[2]}"
  else
    # No type prefix, use entire name as slug
    slug="${branch}"
  fi
  
  # Normalize: lowercase, replace special chars with hyphens
  type=$(echo "${type}" | tr '[:upper:]' '[:lower:]')
  slug=$(echo "${slug}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g')
  
  # Return as "type|slug" for easy parsing
  echo "${type}|${slug}"
}

# Format worktree name from repo name and branch name
# Examples:
#   repo: dotfiles, branch: feat/new-config -> dotfiles-feat-new-config
#   repo: myapp, branch: simple-fix -> myapp-simple-fix
format_worktree_name() {
  local repo_name="$1"
  local branch_name="$2"
  
  local parsed
  parsed="$(parse_branch_name "${branch_name}")"
  local type="${parsed%%|*}"
  local slug="${parsed##*|}"
  
  if [[ -n "${type}" ]]; then
    echo "${repo_name}-${type}-${slug}"
  else
    echo "${repo_name}-${slug}"
  fi
}

# Check if a branch is merged into the main branch (handles regular and squash merges).
# A branch that never diverged (no unique commits) is NOT considered merged.
is_branch_merged() {
  local branch_name="$1"
  local main_branch
  main_branch="$(get_main_branch)"

  local branch_tip main_tip
  branch_tip="$(git rev-parse "${branch_name}" 2>/dev/null)" || return 1
  main_tip="$(git rev-parse "${main_branch}" 2>/dev/null)" || return 1

  # If the branch tip IS the main branch tip, it was just created — not "merged"
  if [[ "${branch_tip}" == "${main_tip}" ]]; then
    return 1
  fi

  # Count unique commits on the branch (not reachable from main)
  local unique_count
  unique_count="$(git rev-list --count "${main_branch}..${branch_name}" 2>/dev/null)" || return 1

  if [[ "${unique_count}" -gt 0 ]]; then
    # Branch has unique commits — check regular merge (covers fast-forward too)
    if git branch --merged "${main_branch}" | grep -qE "^[* +] +${branch_name}$"; then
      return 0
    fi

    # Check squash merge: create a synthetic squash commit and see if it's already in main
    local merge_base tree dangling
    merge_base="$(git merge-base "${main_branch}" "${branch_name}" 2>/dev/null)" || return 1
    tree="$(git rev-parse "${branch_name}^{tree}" 2>/dev/null)" || return 1
    dangling="$(git commit-tree "${tree}" -p "${merge_base}" -m _ 2>/dev/null)" || return 1
    if [[ "$(git cherry "${main_branch}" "${dangling}" 2>/dev/null)" == "-"* ]]; then
      return 0
    fi

    return 1
  fi

  # No unique commits (branch tip is ancestor of main).
  # Check if it was genuinely merged (branch tip is a parent of a merge commit on main)
  if git log --merges --format='%P' --ancestry-path "${branch_tip}..${main_tip}" 2>/dev/null \
     | grep -q "${branch_tip}"; then
    return 0
  fi

  return 1
}

# Check if a worktree exists at the given path
worktree_exists() {
  local worktree_path="$1"
  
  # Use git worktree list --porcelain to get all worktrees
  while IFS= read -r line; do
    if [[ "${line}" =~ ^worktree\ (.+)$ ]]; then
      local wt_path="${BASH_REMATCH[1]}"
      if [[ "${wt_path}" == "${worktree_path}" ]]; then
        return 0
      fi
    fi
  done < <(git worktree list --porcelain)
  
  return 1
}

# Get the branch name for a worktree path
get_worktree_branch() {
  local worktree_path="$1"
  local current_wt=""
  local current_branch=""
  
  while IFS= read -r line; do
    if [[ "${line}" =~ ^worktree\ (.+)$ ]]; then
      current_wt="${BASH_REMATCH[1]}"
    elif [[ "${line}" =~ ^branch\ refs/heads/(.+)$ ]]; then
      current_branch="${BASH_REMATCH[1]}"
      
      # If this is our worktree, return the branch
      if [[ "${current_wt}" == "${worktree_path}" ]]; then
        echo "${current_branch}"
        return 0
      fi
    fi
  done < <(git worktree list --porcelain)
  
  return 1
}

# Check if a branch exists (locally or on remote)
# Returns: "local", "remote", or "none" (always exits with 0)
branch_exists() {
  local branch_name="$1"
  
  # Check local branches
  if git rev-parse --verify "${branch_name}" >/dev/null 2>&1; then
    echo "local"
    return 0
  fi
  
  # Check remote branches
  if git rev-parse --verify "origin/${branch_name}" >/dev/null 2>&1; then
    echo "remote"
    return 0
  fi
  
  echo "none"
  return 0
}

# Print error message in red
error() {
  echo -e "${COLOR_RED}Error: $*${COLOR_RESET}" >&2
}

# Print success message in green
success() {
  echo -e "${COLOR_GREEN}$*${COLOR_RESET}"
}

# Print info message in blue
info() {
  echo -e "${COLOR_BLUE}$*${COLOR_RESET}"
}

# Print warning message in yellow
warning() {
  echo -e "${COLOR_YELLOW}$*${COLOR_RESET}"
}
