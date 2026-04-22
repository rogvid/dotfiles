#!/usr/bin/env bash
# Scan tmux sessions for active agentic coding sessions (claude, codex, pi)
# Output: <colored_dot> <status_word> <session_name> <agent_name> <pane_target>

set -euo pipefail

# Bail early if tmux server isn't running
tmux list-sessions &>/dev/null || exit 0

# --- Build PID tree from single ps snapshot ---
declare -A children  # parent_pid -> space-separated child pids
declare -A comm_map  # pid -> command name

while read -r pid ppid name; do
    [[ -z "$pid" || -z "$ppid" ]] && continue
    comm_map[$pid]="$name"
    children[$ppid]+="$pid "
done < <(ps -eo pid=,ppid=,comm= 2>/dev/null)

# --- Agent detection helpers ---
AGENT_NAMES="claude codex pi"

find_agent_pid() {
    # BFS from root PID through descendant tree, return first agent match
    local root=$1
    local queue=("$root")
    local i=0
    while (( i < ${#queue[@]} )); do
        local current="${queue[$i]}"
        ((i++))
        local name="${comm_map[$current]:-}"
        for agent in $AGENT_NAMES; do
            if [[ "$name" == "$agent" ]]; then
                echo "$current $agent"
                return 0
            fi
        done
        for child in ${children[$current]:-}; do
            queue+=("$child")
        done
    done
    return 1
}

has_children() {
    [[ -n "${children[$1]:-}" ]]
}

# --- Approval patterns for "waiting" detection ---
# Matches tool approval, AskUserQuestion prompts, yes/no confirmations, etc.
APPROVAL_PATTERN='(Allow once|Allow always|Allow|Deny|Enter to select|\[Y/n\]|\[y/N\]|Do you want|Continue\?|[Pp]ermission|[Aa]pprove|[Rr]eject|Press Enter|Proceed\?|[Cc]onfirm|yes/no|Plan mode)'

# --- Scan tmux panes ---
declare -A seen_sessions  # track one entry per session

while IFS= read -r pane_line; do
    # Format: session_name:window.pane PID
    pane_target="${pane_line%% *}"
    pane_pid="${pane_line##* }"
    session_name="${pane_target%%:*}"

    # Skip if we already found an agent in this session
    [[ -n "${seen_sessions[$session_name]:-}" ]] && continue

    # Search descendant tree for agent process
    result=$(find_agent_pid "$pane_pid") || continue

    agent_pid="${result%% *}"
    agent_name="${result##* }"
    seen_sessions[$session_name]=1

    # --- Classify status ---
    if has_children "$agent_pid"; then
        # Agent has child processes → running (executing tools)
        dot='\033[34m●\033[0m'
        status_colored='\033[34mrunning\033[0m'
    else
        # Check pane content for approval/input prompts
        pane_content=$(tmux capture-pane -t "$pane_target" -p -S -20 2>/dev/null) || true
        if echo "$pane_content" | grep -qE "$APPROVAL_PATTERN"; then
            dot='\033[33m●\033[0m'
            status_colored='\033[33mwaiting\033[0m'
        else
            dot='\033[32m●\033[0m'
            status_colored='\033[32midle\033[0m'
        fi
    fi

    agent_colored="\033[36m${agent_name}\033[0m"
    echo -e "$dot $status_colored $session_name $agent_colored $pane_target"

done < <(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_pid}' 2>/dev/null)
