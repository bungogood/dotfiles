# interactive shells only
[[ $- != *i* ]] && return

[[ -r "$HOME/.local/scripts/bash-completion-lazy.sh" ]] && . "$HOME/.local/scripts/bash-completion-lazy.sh"
[[ -r "$HOME/.local/scripts/bash-git-prompt.sh" ]] && . "$HOME/.local/scripts/bash-git-prompt.sh"

# Optional generated hook cache (direnv, etc.)
[[ -r "$HOME/.bashrc.generated" ]] && . "$HOME/.bashrc.generated"

HISTCONTROL=ignorespace:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

_p_user='\[\e[38;5;9m\]'
_p_host='\[\e[0;36m\]'
_p_reset='\[\e[0m\]'
PS1="${_p_user}\u${_p_reset}@${_p_host}\h${_p_reset} \W ${_p_user}\$(__git_prompt_segment)${_p_reset}\\$ "

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
