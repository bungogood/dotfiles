#!/usr/bin/env bash

set -u -o pipefail

dev_session="dev"
dev_window_index="1"
dev_window_name="htop"
return_option="@hop_return_target"

monitor_cmd="htop"
if ! command -v "$monitor_cmd" >/dev/null 2>&1; then
  monitor_cmd="top"
fi

current_session="$(tmux display-message -p '#S')"
current_window="$(tmux display-message -p '#I')"
current_target="${current_session}:${current_window}"
return_target="$(tmux show-options -gqv "$return_option" || true)"

if [[ -z "${TMUX:-}" || -z "$current_session" || -z "$current_window" ]]; then
  exit 0
fi

ensure_dev_window() {
  if ! tmux has-session -t "$dev_session" 2>/dev/null; then
    tmux new-session -d -s "$dev_session" -n "$dev_window_name" "$monitor_cmd"
    tmux set-option -t "$dev_session" base-index 1 >/dev/null 2>&1 || true
    tmux set-option -t "$dev_session" renumber-windows on >/dev/null 2>&1 || true
    return
  fi

  tmux set-option -t "$dev_session" base-index 1 >/dev/null 2>&1 || true
  tmux set-option -t "$dev_session" renumber-windows on >/dev/null 2>&1 || true

  if ! tmux display-message -p -t "${dev_session}:${dev_window_index}" '#{window_id}' >/dev/null 2>&1; then
    tmux new-window -d -t "${dev_session}:${dev_window_index}" -n "$dev_window_name" "$monitor_cmd"
    return
  fi

  existing_name="$(tmux display-message -p -t "${dev_session}:${dev_window_index}" '#W')"
  existing_cmd="$(tmux display-message -p -t "${dev_session}:${dev_window_index}" '#{pane_current_command}')"

  if [[ "$existing_name" == "$dev_window_name" && "$existing_cmd" == "$monitor_cmd" ]]; then
    return
  fi

  mapfile -t window_indices < <(tmux list-windows -t "$dev_session" -F '#I' | sort -nr)
  for index in "${window_indices[@]}"; do
    tmux move-window -d -s "${dev_session}:${index}" -t "${dev_session}:$((index + 1))"
  done

  tmux new-window -d -t "${dev_session}:${dev_window_index}" -n "$dev_window_name" "$monitor_cmd"
}

if [[ -n "$return_target" && "$current_session" == "$dev_session" ]]; then
  if tmux display-message -p -t "$return_target" '#{session_name}' >/dev/null 2>&1; then
    tmux switch-client -t "$return_target"
  else
    tmux display-message "Saved hop target no longer exists"
  fi
  tmux set-option -gu "$return_option" 2>/dev/null || true
  exit 0
fi

if [[ "$current_session" != "$dev_session" ]]; then
  tmux set-option -g "$return_option" "$current_target"
fi

ensure_dev_window
tmux switch-client -t "${dev_session}:${dev_window_index}" || true
exit 0
