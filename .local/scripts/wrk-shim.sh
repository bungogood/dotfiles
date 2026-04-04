#!/usr/bin/env bash

wrk() {
  if [ -n "${COMP_LINE:-}" ]; then
    worktree "$@"
    return $?
  fi

  local dir_path=""
  local exit_code=0

  while IFS= read -r line; do
    if [[ "$line" == __WORKTREE_CD__* ]]; then
      dir_path="${line#__WORKTREE_CD__}"
    else
      printf '%s\n' "$line"
    fi
  done < <(worktree "$@" 2>&1)

  exit_code=${PIPESTATUS[0]}

  if [ -n "$dir_path" ] && [ -d "$dir_path" ]; then
    cd "$dir_path" || return 1
  fi

  return $exit_code
}
