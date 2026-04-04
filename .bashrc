# interactive shells only
[[ $- != *i* ]] && return

. "$HOME/.local/scripts/bash-completion-lazy.sh"
. "$HOME/.local/scripts/bash-git-prompt.sh"
. "$HOME/.local/scripts/wrk-shim.sh"

# History: ignore commands with leading spaces and deduplicate entries.
HISTCONTROL=ignorespace:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# Prompt colors kept local to prompt setup.
_p_user='\[\e[38;5;9m\]'
_p_host='\[\e[0;36m\]'
_p_reset='\[\e[0m\]'
PS1="${_p_user}\u${_p_reset}@${_p_host}\h${_p_reset} \W ${_p_user}\$(__git_prompt_segment)${_p_reset}\\$ "

alias ls='ls --color=always'
alias ll='ls -Alh'  # List detailed information about files
alias la='ls -A'  # List all files (including hidden ones)

# Aliases for convenient file management
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'  # Generate lowercase UUID
alias cls='printf "\33c\e[3J"'
alias activate='source .venv/bin/activate'
alias vim='nvim'
