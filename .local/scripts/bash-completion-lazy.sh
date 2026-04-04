#!/usr/bin/env bash

if [[ "${__BASH_COMPLETION_LAZY_INIT:-0}" == "1" ]]; then
  return 0
fi
__BASH_COMPLETION_LAZY_INIT=1

if shopt -oq posix; then
  return 0
fi

__bash_completion_loaded=0

__load_bash_completion_once() {
  local path
  if [[ "$__bash_completion_loaded" == "1" ]]; then
    return 0
  fi

  for path in \
    /opt/homebrew/etc/bash_completion \
    /usr/local/etc/bash_completion \
    /etc/bash_completion \
    /usr/share/bash-completion/bash_completion \
    /etc/profile.d/bash_completion.sh
  do
    if [ -f "$path" ]; then
      . "$path"
      __bash_completion_loaded=1
      return 0
    fi
  done

  return 1
}

__source_completion_for_cmd() {
  local cmd dir file user_completion_root
  cmd="$1"
  user_completion_root="${BASH_COMPLETION_USER_DIR:-$HOME/.local/share/bash-completion}"

  for dir in \
    "$user_completion_root/completions" \
    "$HOME/.bash_completion.d" \
    /opt/homebrew/etc/bash_completion.d \
    /usr/local/etc/bash_completion.d \
    /etc/bash_completion.d
  do
    for file in "$dir/$cmd" "$dir/${cmd}.bash" "$dir/_$cmd"; do
      if [ -r "$file" ]; then
        . "$file"
        if complete -p "$cmd" >/dev/null 2>&1; then
          return 0
        fi
      fi
    done
  done

  return 1
}

__lazy_bash_completion() {
  local cmd spec fn
  cmd="${COMP_WORDS[0]}"

  __load_bash_completion_once || return 0

  spec="$(complete -p "$cmd" 2>/dev/null || true)"
  if [[ "$spec" =~ -F[[:space:]]+([^[:space:]]+) ]]; then
    fn="${BASH_REMATCH[1]}"
    if [[ "$fn" != "__lazy_bash_completion" ]] && declare -F "$fn" >/dev/null 2>&1; then
      "$fn" "$@"
      return
    fi
  fi

  if declare -F _completion_loader >/dev/null 2>&1; then
    _completion_loader "$cmd" >/dev/null 2>&1 || true
    spec="$(complete -p "$cmd" 2>/dev/null || true)"
    if [[ "$spec" =~ -F[[:space:]]+([^[:space:]]+) ]]; then
      fn="${BASH_REMATCH[1]}"
      if [[ "$fn" != "__lazy_bash_completion" ]] && declare -F "$fn" >/dev/null 2>&1; then
        "$fn" "$@"
      fi
    fi
  else
    __source_completion_for_cmd "$cmd" >/dev/null 2>&1 || true
    spec="$(complete -p "$cmd" 2>/dev/null || true)"
    if [[ "$spec" =~ -F[[:space:]]+([^[:space:]]+) ]]; then
      fn="${BASH_REMATCH[1]}"
      if [[ "$fn" != "__lazy_bash_completion" ]] && declare -F "$fn" >/dev/null 2>&1; then
        "$fn" "$@"
      fi
    fi
  fi
}

complete -o bashdefault -o default -D -F __lazy_bash_completion
