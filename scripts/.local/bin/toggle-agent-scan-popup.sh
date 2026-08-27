#!/bin/bash
# Toggle an agent-scan popup. Works as a true same-key toggle because the
# popup hosts a nested tmux client: the M-2 root binding is active inside it,
# so pressing M-2 again runs this script in the nested client and tears the
# ephemeral session down (which makes the -E popup exit).

session="agent-scan"

if [ "$(tmux display-message -p -F '#{session_name}')" = "$session" ]; then
    tmux kill-session -t "$session"
else
    tmux popup -d '#{pane_current_path}' -xC -yC -w80% -h75% \
        -E "tmux new -s '$session' 'watch -ctn1 agent-scan scan'"
fi
