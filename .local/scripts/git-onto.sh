#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  printf 'usage: git skip [branch|remote/branch]\n'
  printf 'examples:\n'
  printf '  git skip\n'
  printf '  git skip main\n'
  printf '  git skip origin/main\n'
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'not inside a git repository\n' >&2
  exit 1
fi

has_local_branch() {
  git show-ref --verify --quiet "refs/heads/$1"
}

has_remote() {
  git remote | grep -qx "$1"
}

has_remote_branch() {
  local remote="$1"
  local branch="$2"
  git ls-remote --exit-code --heads "$remote" "$branch" >/dev/null 2>&1
}

resolve_default_target() {
  local remote branch
  if has_remote origin; then
    remote="origin"
    if branch="$(git symbolic-ref --quiet --short refs/remotes/${remote}/HEAD 2>/dev/null)"; then
      branch="${branch#${remote}/}"
      printf '%s/%s\n' "$remote" "$branch"
      return
    fi
    for branch in main master; do
      if has_remote_branch "$remote" "$branch"; then
        printf '%s/%s\n' "$remote" "$branch"
        return
      fi
    done
  fi

  for branch in main master; do
    if has_local_branch "$branch"; then
      printf '%s\n' "$branch"
      return
    fi
  done

  printf 'could not determine default base branch (tried origin/HEAD, origin/main, origin/master, local main/master)\n' >&2
  exit 1
}

input_target="${1:-}"
target="$input_target"
fetch_remote=""
fetch_branch=""

if [[ -z "$target" ]]; then
  target="$(resolve_default_target)"
fi

if [[ "$target" == */* ]]; then
  fetch_remote="${target%%/*}"
  fetch_branch="${target#*/}"
  if ! has_remote "$fetch_remote"; then
    printf 'remote not found: %s\n' "$fetch_remote" >&2
    exit 1
  fi
elif has_local_branch "$target"; then
  :
elif has_remote origin && has_remote_branch origin "$target"; then
  fetch_remote="origin"
  fetch_branch="$target"
  target="origin/$target"
else
  printf 'branch not found locally or on origin: %s\n' "$target" >&2
  exit 1
fi

if [[ -n "$fetch_remote" ]]; then
  git fetch "$fetch_remote" "$fetch_branch"
fi

stashed=0
if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  git stash push -u -m "git-skip auto-stash"
  stashed=1
fi

if git rebase "$target"; then
  if [[ "$stashed" == "1" ]]; then
    git stash pop
  fi
else
  if [[ "$stashed" == "1" ]]; then
    printf 'rebase failed; your changes are stashed. inspect with: git stash list\n' >&2
  fi
  exit 1
fi
