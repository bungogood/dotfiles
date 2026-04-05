#!/usr/bin/env bash

set -euo pipefail

dry_run=0
args=()

looks_like_conventional_header() {
  local text="$1"
  local re='^(fix|feat|chore|docs|style|refactor|perf|test|build|ci|revert)(\([^)]+\))?(!)?:[[:space:]].+'
  [[ "$text" =~ $re ]]
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      printf 'usage: git infer [--dry-run] [message ...]\n'
      exit 0
      ;;
    --)
      shift
      args+=("$@")
      break
      ;;
    -*)
      printf 'unknown option: %s\nusage: git infer [--dry-run] [message ...]\n' "$1" >&2
      exit 1
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

slug_to_words() {
  local text="$1"
  text="${text//-/ }"
  text="${text//_/ }"
  printf '%s' "$text"
}

capitalize_first() {
  local text="$1"
  local first rest
  first="${text:0:1}"
  rest="${text:1}"
  printf '%s%s' "$(printf '%s' "$first" | tr '[:lower:]' '[:upper:]')" "$rest"
}

cap_after_ticket_for_kind() {
  local kind="$1"
  local default="${GIT_MSG_CAP_AFTER_TICKET:-0}"
  local jira_default="${GIT_MSG_CAP_AFTER_JIRA:-$default}"
  local numeric_default="${GIT_MSG_CAP_AFTER_NUMERIC:-$default}"

  if [[ "$kind" == "jira" ]]; then
    printf '%s' "$jira_default"
  elif [[ "$kind" == "numeric" ]]; then
    printf '%s' "$numeric_default"
  else
    printf '0'
  fi
}

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD)"
ticket=""
ticket_kind=""
rest="$branch"

if [[ "$branch" =~ ^([A-Za-z][A-Za-z0-9]*-[0-9]+)-(.+)$ ]]; then
  ticket="${BASH_REMATCH[1]}"
  ticket_kind="jira"
  rest="${BASH_REMATCH[2]}"
elif [[ "$branch" =~ ^([0-9]+)-(.+)$ ]]; then
  ticket="#${BASH_REMATCH[1]}"
  ticket_kind="numeric"
  rest="${BASH_REMATCH[2]}"
fi

type=""
tail="$rest"
if [[ "$rest" =~ ^(fix|feat|chore|docs|style|refactor|perf|test|build|ci|revert)-(.+)$ ]]; then
  type="${BASH_REMATCH[1]}"
  tail="${BASH_REMATCH[2]}"
fi

explicit_header=0
if [[ "${#args[@]}" -gt 0 ]]; then
  message="${args[*]}"
  if looks_like_conventional_header "$message"; then
    explicit_header=1
  fi
else
  message="$(slug_to_words "$tail")"
fi

if [[ -n "$ticket" ]] && [[ "$(cap_after_ticket_for_kind "$ticket_kind")" == "1" ]]; then
  if [[ -n "$type" ]]; then
    type="$(capitalize_first "$type")"
  else
    message="$(capitalize_first "$message")"
  fi
fi

if [[ -n "$type" ]] && [[ "$explicit_header" == "0" ]]; then
  message="$type: $message"
fi

if [[ -n "$ticket" ]]; then
  message="$ticket $message"
fi

if [[ "$dry_run" == "1" ]]; then
  printf '%s\n' "$message"
  exit 0
fi

git commit -m "$message"
