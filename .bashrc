# ~/.bashrc

[[ -r "$HOME/.local/scripts/bash-completion-lazy.sh" ]] && . "$HOME/.local/scripts/bash-completion-lazy.sh"

# Optional generated hook cache (direnv, etc.)
[[ -r "$HOME/.bashrc.generated" ]] && . "$HOME/.bashrc.generated"

HISTCONTROL=ignorespace:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

alias ls='ls --color=always'
alias ll='ls -Alh'
alias la='ls -A'
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'
alias cls='printf "\33c\e[3J"'
alias activate='source .venv/bin/activate'
alias vim='nvim'

export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$GOENV_ROOT/shims:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

eval "$(starship init bash)"
