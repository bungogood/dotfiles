#!/usr/bin/env bash

if [[ "${__BASH_GIT_PROMPT_INIT:-0}" == "1" ]]; then
  return 0
fi
__BASH_GIT_PROMPT_INIT=1

__git_prompt_loaded=0

__load_git_prompt_once() {
  local path git_exec_path
  if [[ "$__git_prompt_loaded" == "1" ]]; then
    return 0
  fi

  if declare -F __git_ps1 >/dev/null 2>&1; then
    __git_prompt_loaded=1
    return 0
  fi

  git_exec_path="$(git --exec-path 2>/dev/null || true)"

  for path in \
    "$HOME/.git-prompt.sh" \
    /opt/homebrew/etc/bash_completion.d/git-prompt.sh \
    /usr/local/etc/bash_completion.d/git-prompt.sh \
    /usr/share/git/completion/git-prompt.sh \
    /usr/share/git-core/contrib/completion/git-prompt.sh \
    "$git_exec_path/../share/git/completion/git-prompt.sh" \
    "$git_exec_path/../share/git-core/contrib/completion/git-prompt.sh"
  do
    if [ -f "$path" ]; then
      . "$path"
      if declare -F __git_ps1 >/dev/null 2>&1; then
        __git_prompt_loaded=1
        return 0
      fi
    fi
  done

  return 1
}

__git_prompt_segment() {
  __load_git_prompt_once || return
  __git_ps1 '(%s) '
}
