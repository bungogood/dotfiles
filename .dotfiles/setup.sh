#!/usr/bin/env bash
set -e

DOTBIN="$HOME/.dotfiles/bin"
mkdir -p "$DOTBIN"

# Link vim to nvim if needed
if command -v nvim >/dev/null && [ ! -f "$DOTBIN/vim" ]; then
  ln -s "$(command -v nvim)" "$DOTBIN/vim"
  echo "Linked vim -> nvim"
fi

# Optionally vi too
if command -v nvim >/dev/null && [ ! -f "$DOTBIN/vi" ]; then
  ln -s "$(command -v nvim)" "$DOTBIN/vi"
  echo "Linked vi -> nvim"
fi
