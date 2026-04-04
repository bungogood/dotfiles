#!/usr/bin/env bash

set -euo pipefail

DOTFILES_REPO="$HOME/.dotfiles"
BASE_BACKUP_DIR="$HOME/.dotfiles.bak"
BACKUP_DIR="$BASE_BACKUP_DIR"

if [ -e "$BACKUP_DIR" ]; then
  i=1
  while [ -e "${BASE_BACKUP_DIR}.$i" ]; do
    i=$((i + 1))
  done
  BACKUP_DIR="${BASE_BACKUP_DIR}.$i"
fi

if [ ! -d "$DOTFILES_REPO" ]; then
  git clone --bare --branch mac https://github.com/bungogood/dotfiles.git "$DOTFILES_REPO"
fi

config() {
  /usr/bin/git --git-dir="$DOTFILES_REPO/" --work-tree="$HOME" "$@"
}

backup_file() {
  file="$1"
  case "$file" in
    .dotfiles/*) return ;;
  esac
  [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ] || return
  mkdir -p "$BACKUP_DIR/$(dirname "$file")"
  mv "$HOME/$file" "$BACKUP_DIR/$file"
}

if config checkout >/dev/null 2>&1; then
  echo "Checked out config."
else
  echo "Backing up pre-existing dot files to $BACKUP_DIR."
  mkdir -p "$BACKUP_DIR"

  # common top-level conflicts from this repo
  backup_file "README.md"
  backup_file "LICENSE"

  checkout_output="$(config checkout 2>&1 || true)"
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    backup_file "$file"
  done < <(printf '%s\n' "$checkout_output" | awk '/^[[:space:]]+[^[:space:]]/ {print $1}')
  config checkout >/dev/null
fi

config config status.showUntrackedFiles no
config remote set-url origin git@github.com:bungogood/dotfiles.git

for file in README.md LICENSE; do
  if config ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    config update-index --skip-worktree -- "$file"
  fi
  rm -f "$HOME/$file"
done
