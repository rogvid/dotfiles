#!/usr/bin/env bash
# toggle-tmux-popup.sh - M-3: the scratch session "popup" in a popup,
# created on first use. M-3 in it closes it; M-3 in another popup, such as
# M-1's orchestrator, swaps that one for it (see tmux-popup).

set -euo pipefail

if [[ "$(tmux display-message -p '#{session_name}')" == popup ]]; then
    tmux detach-client
    exit 0
fi
# The popup's client attaches to this server by its socket: a bare tmux in
# there would reach the default one.
socket="$(printf '%q' "$(tmux display-message -p '#{socket_path}')")"
tmux-popup -d '#{pane_current_path}' -xC -yC -w80% -h75% -E \
    "env -u TMUX tmux -S ${socket} new-session -A -s popup"
