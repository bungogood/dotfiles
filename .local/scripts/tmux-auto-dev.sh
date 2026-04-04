#!/usr/bin/env bash

set -euo pipefail

if [[ -n "${TMUX:-}" ]]; then
  exit 0
fi

if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
  exit 0
fi

if ! command -v tmux >/dev/null 2>&1; then
  exit 0
fi

if [[ ! -t 0 || ! -t 1 ]]; then
  exit 0
fi

session="dev"

if tmux has-session -t "$session" 2>/dev/null; then
  exec tmux attach-session -t "$session"
fi

tmux new-session -d -s "$session" -n htop "htop"
tmux new-window -t "$session:2" -n bash

exec tmux attach-session -t "$session:2"
