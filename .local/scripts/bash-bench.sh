#!/usr/bin/env bash

set -euo pipefail

if ! command -v hyperfine >/dev/null 2>&1; then
  printf 'hyperfine is not installed. Install it with: brew install hyperfine\n' >&2
  exit 1
fi

loops="${1:-30}"
runs="${2:-20}"
warmup="${3:-3}"
outfile="${TMPDIR:-/tmp}/bash-bench-${USER}.json"

printf 'Bash startup benchmark\n'
printf 'loops per sample: %s, runs: %s, warmup: %s\n\n' "$loops" "$runs" "$warmup"

hyperfine -N --warmup "$warmup" --runs "$runs" --export-json "$outfile" \
  "bash -lc 'for ((i=0;i<${loops};i++)); do bash -i -c exit; done'" \
  "bash -lc 'for ((i=0;i<${loops};i++)); do bash --noprofile --norc -i -c exit; done'"

mapfile -t means < <(
  awk -F: '/"mean"/ { gsub(/[ ,]/, "", $2); print $2 }' "$outfile"
)

if (( ${#means[@]} >= 2 )); then
  awk -v full_sec="${means[0]}" -v base_sec="${means[1]}" -v loops="$loops" 'BEGIN {
    full_ms = (full_sec * 1000.0) / loops
    base_ms = (base_sec * 1000.0) / loops
    overhead = full_ms - base_ms
    printf "\nPer-shell estimate\n"
    printf "interactive startup: %.3f ms\n", full_ms
    printf "bash baseline:       %.3f ms\n", base_ms
    printf "config overhead:     %.3f ms\n", overhead
  }'
else
  printf '\nCould not parse hyperfine JSON. Check: %s\n' "$outfile" >&2
fi
