#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
  printf 'Usage: add-completion <cmd> [alias ...]\n' >&2
  exit 1
fi

cmd="$1"
shift || true
aliases=("$@")

if ! command -v "$cmd" >/dev/null 2>&1; then
  printf 'Command not found: %s\n' "$cmd" >&2
  exit 1
fi

completion_dir="$HOME/.local/share/bash-completion/completions"
mkdir -p "$completion_dir"

target_file="$completion_dir/$cmd"
"$cmd" completion bash > "$target_file"

completion_func=""
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*complete[[:space:]].*-F[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)[[:space:]]*$ ]]; then
    completion_func="${BASH_REMATCH[1]}"
    break
  fi
done < "$target_file"

if [ -n "$completion_func" ]; then
  {
    printf '\n# extra completion bindings (managed by add-completion)\n'
    for bind_name in "$cmd" "${aliases[@]}"; do
      [ -z "$bind_name" ] && continue
      printf 'if [[ $(type -t compopt) = "builtin" ]]; then\n'
      printf '    complete -o default -F %s %s\n' "$completion_func" "$bind_name"
      printf 'else\n'
      printf '    complete -o default -o nospace -F %s %s\n' "$completion_func" "$bind_name"
      printf 'fi\n'
    done
  } >> "$target_file"
fi

for alias_name in "${aliases[@]}"; do
  [ -z "$alias_name" ] && continue
  alias_file="$completion_dir/$alias_name"
  rm -f "$alias_file"
  ln -s "$target_file" "$alias_file"
done

printf 'Installed completion: %s\n' "$target_file"
if [ "${#aliases[@]}" -gt 0 ]; then
  printf 'Linked aliases: %s\n' "${aliases[*]}"
fi
