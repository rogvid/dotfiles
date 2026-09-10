#!/bin/bash
# Claude Code statusline: model + dir + git branch/status, context usage, session cost.

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
IN_TOK=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOK=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; DIM='\033[2m'; RESET='\033[0m'

# --- line 1: model, dir, git ---
GIT_SEGMENT=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -z "$BRANCH" ] && BRANCH=$(git rev-parse --short HEAD 2>/dev/null)

    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    AHEAD=0; BEHIND=0
    UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
    if [ -n "$UPSTREAM" ]; then
        AHEAD=$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
        BEHIND=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
    fi

    STATUS=""
    [ "$STAGED" -gt 0 ] && STATUS="${STATUS}${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && STATUS="${STATUS}${YELLOW}~${MODIFIED}${RESET}"
    [ "$UNTRACKED" -gt 0 ] && STATUS="${STATUS}${DIM}?${UNTRACKED}${RESET}"
    [ "$AHEAD" -gt 0 ] && STATUS="${STATUS} ${CYAN}↑${AHEAD}${RESET}"
    [ "$BEHIND" -gt 0 ] && STATUS="${STATUS} ${RED}↓${BEHIND}${RESET}"

    GIT_SEGMENT=" | 🌿 ${BRANCH}"
    [ -n "$STATUS" ] && GIT_SEGMENT="${GIT_SEGMENT} ${STATUS}"
fi

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}${GIT_SEGMENT}"

# --- line 2: context usage + cost ---
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /█}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

COST_FMT=$(LC_NUMERIC=C printf '$%.2f' "$COST")
MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))
TOK_TOTAL=$((IN_TOK + OUT_TOK))

echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% (${TOK_TOTAL} tok) | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
