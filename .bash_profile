# Homebrew env once per login
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Source interactive config
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# Auto-enter tmux dev session for login shells.
[ -x "$HOME/.local/scripts/tmux-auto-dev.sh" ] && "$HOME/.local/scripts/tmux-auto-dev.sh"
